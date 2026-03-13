
/**
 * 기상청_단기예보 ((구)_동네예보) 조회서비스
 *  : 기상청 초단기실황조회 API에서 날씨 정보를 가져와 객체로 반환하는 함수
 *  : 초단기실황조회(현재날씨상태를 실시간 조회), 관측값, 현재 날씨상태
 * 
 * @param {object} options - API 호출에 필요한 설정 객체
 * @param {string} options.serviceKey - 공공 데이터 포털에서 발급받은 서비스 키 (필수)
 * @param {number} options.latitude - 조회할 지역의 위도 (필수)
 * @param {number} options.longitude - 조회할 지역의 경도 (필수)
 * @returns {Promise<object|null>} 날씨 정보 객체 또는 오류 발생 시 null을 반환하는 Promise
 */
async function getUltraSrtNcstWeather(options) {
    const { serviceKey, latitude, longitude } = options;

    if (!serviceKey || !latitude || !longitude) {
        console.error("Missing required options: serviceKey, latitude, or longitude.");
        return null;
    }

    const API_URL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst";

    // 현재 시간을 기준으로 base_date와 base_time 계산
    // 초단기실황은 매시 30분에 발표 (정시부터 30분까지는 이전 시간 30분 데이터 사용)
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const today = `${year}${month}${day}`;

    let baseHour = now.getHours();
    let baseMinute = now.getMinutes();

    // 30분 이하면 직전 시간으로 설정 (예: 14:29 -> base_time: 1400)
    // 30분 이상이면 현재 시간 30분으로 설정 (예: 14:31 -> base_time: 1430)
    // 00시 00분~30분이면 전날 23시 30분으로 설정
    if (baseMinute < 30) {
        baseHour -= 1;
        baseMinute = 30;
		
        // 자정이 넘어간 경우 전날로 설정
        if (baseHour < 0) {
            baseHour = 23;
            now.setDate(now.getDate() - 1);
            const prevYear = now.getFullYear();
            const prevMonth = String(now.getMonth() + 1).padStart(2, '0');
            const prevDay = String(now.getDate()).padStart(2, '0');
            options.baseDate = `${prevYear}${prevMonth}${prevDay}`;
        } else {
            options.baseDate = today;
        }
    } else {
        baseMinute = 30;
        options.baseDate = today;
    }
    options.baseTime = `${String(baseHour).padStart(2, '0')}${String(baseMinute).padStart(2, '0')}`;

    // 위도/경도를 격자 좌표로 변환
    const { nx, ny } = convertToGridCoordinates(latitude, longitude);

    let params = new URLSearchParams({
        dataType: 'JSON',
        base_date: options.baseDate,
        base_time: options.baseTime,
        nx: nx,
        ny: ny,
        numOfRows: 10, // (T1H, RN1, REH, WSD, UUU, VVV, PTY, VEC)
        pageNo: 1
    }).toString();
	params = 'serviceKey=' + serviceKey + '&' + params;

    const requestUrl = `${API_URL}?${params}`;

	const element = document.querySelector('#loadingLayout');
	if(element) {
		element.style.display = 'block';
	}
		
    try {
        // console.log(`nx: ${nx}, ny: ${ny}`);
        // console.log(`URL: ${requestUrl}`);

        const response = await fetch(requestUrl);

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`HTTP error! status: ${response.status}, message: ${errorText}`);
        }

        const data = await response.json();

        // API 응답 구조 확인(resultCode, items)
        if (data.response && data.response.header && data.response.header.resultCode === '00') {
            const items = data.response.body.items.item;
            if (!items || items.length === 0) {
                console.warn("[Weather API] 해당 시간대의 날씨 정보가 존재하지 않음.");
                return null;
            }

            // 필요한 날씨 정보 추출하여 객체로 구성
            const weatherData = {};
            items.forEach(item => {
                // 각 카테고리(PTY, RN1 등)에 따라 값을 할당
                switch (item.category) {
                    case 'T1H': // 기온 (섭씨)
                        weatherData.temperature = item.obsrValue;
                        break;
					case 'PTY': // 강수 형태 (코드 값)
					    // 0: 맑음, 1: 비, 2: 비/눈, 3: 눈, 4: 소나기, 5: 빗방울, 6: 빗방울눈날림, 7: 눈날림
					    weatherData.ptyDescription = getPtyDescription(item.obsrValue);
						weatherData.ptyIcon = getPtyIcon(item.obsrValue);
						weatherData.ptyCode = item.obsrValue;
					    break;
                    case 'RN1': // 1시간 강수량 (mm)
                        weatherData.precipitation1h = item.obsrValue;
                        break;
                    case 'REH': // 습도 (%)
                        weatherData.humidity = item.obsrValue;
                        break;
                    case 'WSD': // 풍속 (m/s)
                        weatherData.windSpeed = item.obsrValue;
                        break;
                    case 'UUU': // 동서 바람 성분 (m/s) : 동(+표기), 서(-표기)
                        weatherData.windComponentEW = item.obsrValue;
                        break;
                    case 'VVV': // 남북 바람 성분 (m/s) : 북(+표기), 남(-표기)
                        weatherData.windComponentNS = item.obsrValue;
                        break;
                    case 'VEC': // 풍향 (deg)
                        weatherData.windDirection = item.obsrValue;
                        weatherData.windText = getWindDirectionText(parseFloat(item.obsrValue)).substring(0, 1);						
                        break;
                }
            });

			let vec = parseFloat(weatherData.windDirection) || 0; // 풍향
			let wsd = parseFloat(weatherData.windSpeed) || 0; // 풍속
			
            weatherData.baseDate = options.baseDate;
            weatherData.baseTime = options.baseTime;
			weatherData.dateTime = `${options.baseDate.substring(0, 4)}년 ${options.baseDate.substring(4, 6)}월 ${options.baseDate.substring(6, 8)}일 ${options.baseTime.substring(0, 2)}시 ${options.baseTime.substring(2, 4)}분`;
			
			weatherData.wind = formatWind(vec, wsd); // 바람
            weatherData.nx = nx;
            weatherData.ny = ny;

            // console.log("[Weather API] Successfully parsed weather data:", weatherData);
            return weatherData;

        } else if (data.response && data.response.header && data.response.header.resultCode !== '00') {
            const resultMsg = data.response.header.resultMsg || "Unknown error";
            console.error(`[Weather API] API call failed with code: ${data.response.header.resultCode}, message: ${resultMsg}`);
            return null;
        } else {
            console.error("[Weather API] Unexpected API response structure:", data);
            return null;
        }
    } catch (error) {
        console.error("[Weather API] Failed to fetch weather data:", error);
        return null;
	} finally {
		if(element) {
			element.style.display = 'none';
		}
	}
}

/**
 * 기상청_단기예보 ((구)_동네예보) 조회서비스
 *  : 기상청 초단기실황조회 API에서 날씨 정보를 가져와 객체로 반환하는 함수
 *  : 초단기예보정보(수치 모델로 계산한 10분 단위 예보), 예측값, 예보시점부터 6시간 이내의 예보
 * 
 * @param {object} options - API 호출에 필요한 설정 객체
 * @param {string} options.serviceKey - 공공 데이터 포털에서 발급받은 서비스 키 (필수)
 * @param {number} options.latitude - 조회할 지역의 위도 (필수)
 * @param {number} options.longitude - 조회할 지역의 경도 (필수)
 * @returns {Promise<object|null>} 날씨 정보 객체 또는 오류 발생 시 null을 반환하는 Promise
 */
async function getUltraSrtFcstWeather(options) {
    const { serviceKey, latitude, longitude } = options;

    if (!serviceKey || !latitude || !longitude) {
        console.error("Missing required options: serviceKey, latitude, or longitude.");
        return null;
    }

    const API_URL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst";

    // 현재 시간을 기준으로 base_date와 base_time 계산
    // 초단기실황은 매시 30분에 발표 (정시부터 30분까지는 이전 시간 30분 데이터 사용)
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const today = `${year}${month}${day}`;

    let baseHour = now.getHours();
    let baseMinute = now.getMinutes();

    // 30분 이하면 직전 시간으로 설정 (예: 14:29 -> base_time: 1400)
    // 30분 이상이면 현재 시간 30분으로 설정 (예: 14:31 -> base_time: 1430)
    // 00시 00분~30분이면 전날 23시 30분으로 설정
    if (baseMinute < 30) {
        baseHour -= 1;
        baseMinute = 30;
		
        // 자정이 넘어간 경우 전날로 설정
        if (baseHour < 0) {
            baseHour = 23;
            now.setDate(now.getDate() - 1);
            const prevYear = now.getFullYear();
            const prevMonth = String(now.getMonth() + 1).padStart(2, '0');
            const prevDay = String(now.getDate()).padStart(2, '0');
            options.baseDate = `${prevYear}${prevMonth}${prevDay}`;
        } else {
            options.baseDate = today;
        }
    } else {
        baseMinute = 30;
        options.baseDate = today;
    }
    options.baseTime = `${String(baseHour).padStart(2, '0')}${String(baseMinute).padStart(2, '0')}`;

    // 위도/경도를 격자 좌표로 변환
    const { nx, ny } = convertToGridCoordinates(latitude, longitude);

	let params = new URLSearchParams({
	    dataType: 'JSON',
	    base_date: options.baseDate,
	    base_time: options.baseTime,
	    nx: nx,
	    ny: ny,
	    numOfRows: 100,
	    pageNo: 1
	}).toString();
	params = 'serviceKey=' + serviceKey + '&' + params;

	const requestUrl = `${API_URL}?${params}`;

	const element = document.querySelector('#loadingLayout');
	if(element) {
		element.style.display = 'block';
	}
		
    try {
        // console.log(`nx: ${nx}, ny: ${ny}`);
        // console.log(`URL: ${requestUrl}`);

        const response = await fetch(requestUrl);

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`HTTP error! status: ${response.status}, message: ${errorText}`);
        }

        const data = await response.json();

        // API 응답 구조 확인(resultCode, items)
        if (data.response && data.response.header && data.response.header.resultCode === '00') {
            const items = data.response.body.items.item;
            if (!items || items.length === 0) {
                console.warn("[Weather API] 해당 시간대의 날씨 정보가 존재하지 않음.");
                return null;
            }

            // 필요한 날씨 정보 추출하여 객체 배열로 구성
            const weatherData = {};
            items.forEach(item => {
				const fcstTime = item.fcstTime; // 예보 시간 (HHMM)
				const fcstDate = item.fcstDate; // 예보 날짜 (YYYYMMDD)

				if (!weatherData[fcstDate]) {
					weatherData[fcstDate] = {};
				}
				if (!weatherData[fcstDate][fcstTime]) {
					weatherData[fcstDate][fcstTime] = {};
				}
				
                // 각 카테고리(PTY, RN1 등)에 따라 값을 할당
                switch (item.category) {
                    case 'T1H': // 기온 (섭씨)
                        weatherData[fcstDate][fcstTime].temperature = item.fcstValue;
                        break;
                    case 'RN1': // 1시간 강수량 (mm)
                         weatherData[fcstDate][fcstTime].precipitation1h = item.fcstValue;
                        break;
					case 'SKY': // 하늘상태 (1: 맑음, 3: 구름많음, 4: 흐림)
					    weatherData[fcstDate][fcstTime].skyState = getSkyDescription(item.fcstValue);
						weatherData[fcstDate][fcstTime].skyIcon = getSkyIcon(item.fcstValue);
					    break;						
                    case 'REH': // 습도 (%)
                        weatherData[fcstDate][fcstTime].humidity = item.fcstValue;
                        break;
                    case 'WSD': // 풍속 (m/s)
                        weatherData[fcstDate][fcstTime].windSpeed = item.fcstValue;
                        break;
                    case 'UUU': // 동서 바람 성분 (m/s)
                        weatherData[fcstDate][fcstTime].windSpeedEW = item.fcstValue;
                        break;
                    case 'VVV': // 남북 바람 성분 (m/s)
                        weatherData[fcstDate][fcstTime].windSpeedNS = item.fcstValue;
                        break;
                    case 'PTY': // 강수 형태 (코드 값)
                        // 0: 없음, 1: 비, 2: 비/눈, 3: 눈, 4: 소나기, 5: 빗방울, 6: 빗방울눈날림, 7: 눈날림
						weatherData[fcstDate][fcstTime].ptyDescription = getPtyForecastDescription(item.fcstValue);
						weatherData[fcstDate][fcstTime].ptyIcon = getPtyIcon(item.fcstValue);
						weatherData[fcstDate][fcstTime].ptyCode = item.fcstValue;
						break;
                    case 'VEC': // 풍향 (deg)
                        weatherData[fcstDate][fcstTime].windDirection = item.fcstValue;
                        weatherData[fcstDate][fcstTime].windText = getWindDirectionText(parseFloat(item.fcstValue)).substring(0, 1);
                        break;
                }
            });

			// 가공된 데이터를 시간대별 객체 배열로 변환
			const weathers = [];
			for (const date in weatherData) {
			  for (const time in weatherData[date]) {
			    weathers.push({
			      fcstDate: date,
			      fcstTime: time,
			      ...weatherData[date][time]
			    });
			  }
			}

			// 날짜 및 시간 순서로 정렬
			weathers.sort((a, b) => {
			  const dateTimeA = parseInt(a.fcstDate + a.fcstTime);
			  const dateTimeB = parseInt(b.fcstDate + b.fcstTime);
			  return dateTimeA - dateTimeB;
			});

			let dateTime = `${options.baseDate.substring(0, 4)}년 ${options.baseDate.substring(4, 6)}월 ${options.baseDate.substring(6, 8)}일 ${options.baseTime.substring(0, 2)}시 ${options.baseTime.substring(2, 4)}분`;
			
			const result = {dateTime: dateTime, weathers: weathers};

			return result; // 기준날짜와 정렬된 날씨 정보 배열을 반환

        } else if (data.response && data.response.header && data.response.header.resultCode !== '00') {
            const resultMsg = data.response.header.resultMsg || "Unknown error";
            console.error(`[Weather API] API call failed with code: ${data.response.header.resultCode}, message: ${resultMsg}`);
            return null;
        } else {
            console.error("[Weather API] Unexpected API response structure:", data);
            return null;
        }
    } catch (error) {
        console.error("[Weather API] Failed to fetch weather data:", error);
        return null;
	} finally {
		if(element) {
			element.style.display = 'none';
		}
	}
}

// 초단기실황 PTY(강수형태)
function getPtyDescription(code) {
    const map = {
        '0': '맑음',
        '1': '비',
        '2': '비/눈 (진눈깨비)',
        '3': '눈',
        '5': '빗방울',
        '6': '빗방울/눈날림',
        '7': '눈날림'
    };
    return map[code] || '알 수 없음';
}

// 초단기예보 PTY(강수형태)
function getPtyForecastDescription(ptyCode) {
    const ptyMap = {
        '0': '없음',
        '1': '비',
        '2': '비/눈(진눈깨비)',
        '3': '눈',
        '5': '빗방울',
        '6': '빗방울/눈날림',
        '7': '눈날림'
    };

    return ptyMap[ptyCode.toString()] || '알 수 없음';
}

// 초단기실황 PTY / 초단기예보 PTY (강수형태) 아이콘
function getPtyIcon(code) {
    const map = {
        '0': '☀️',
        '1': '🌧️',
        '2': '🌧️❄️',
        '3': '❄️',
        '5': '💧',
        '6': '🌨️',
        '7': '💨❄️'
    };
    return map[code] || '❓';
}

// 초단기예보 SKY(하늘상태)
function getSkyDescription(skyCode) {
    const skyMap = {
        '1': '맑음',
        '3': '구름 많음',
        '4': '흐림'
    };

    return skyMap[skyCode.toString()] || '알 수 없음';
}

function getSkyIcon(code) {
    const map = {
        '1': '☀️',
        '3': '☁️',
        '4': '⛅️'
    };
    return map[code] || '❓';
}

// 풍향(바람 방향)
function getWindDirectionText(degree) {
  const directions = [
    "북", "북북동", "북동", "동북동",
    "동", "동남동", "남동", "남남동",
    "남", "남남서", "남서", "서남서",
    "서", "서북서", "북서", "북북서"
  ];

  const index = Math.floor((degree + 11.25) / 22.5) % 16;
  return directions[index];
}

// 바람
function formatWind(vec, wsd) {
  const direction = getWindDirectionText(vec);
  return `${direction} ${wsd.toFixed(1)} m/s`;
}

/**
 * 위도/경도를 기상청 격자 좌표(nx, ny)로 변환하는 함수
 *
 * @param {number} lat - 위도
 * @param {number} lon - 경도
 * @returns {object} { nx, ny } 형태의 객체
 */
function convertToGridCoordinates(lat, lon) {
    const RE = 6371.00877; // 지구 반경 (km)
    const GRID = 5.0;     // 격자 간격 (km)
    const SLAT1 = 30.0;   // 표준 위도1
    const SLAT2 = 60.0;   // 표준 위도2
    const OLON = 126.0;   // 기준점 경도
    const OLAT = 38.0;    // 기준점 위도
    const XO = 43;        // 기준점 X좌표
    const YO = 136;       // 기준점 Y좌표

    const DEGRAD = Math.PI / 180.0;
    // const RADDEG = 180.0 / Math.PI;

    const re = RE / GRID;
    const slat1 = SLAT1 * DEGRAD;
    const slat2 = SLAT2 * DEGRAD;
    const olon = OLON * DEGRAD;
    const olat = OLAT * DEGRAD;

    let sn = Math.tan(Math.PI * 0.25 + slat2 * 0.5) / Math.tan(Math.PI * 0.25 + slat1 * 0.5);
    sn = Math.log(Math.cos(slat1) / Math.cos(slat2)) / Math.log(sn);
    let sf = Math.tan(Math.PI * 0.25 + slat1 * 0.5);
    sf = Math.pow(sf, sn) * Math.cos(slat1) / sn;
    let ro = Math.tan(Math.PI * 0.25 + olat * 0.5);
    ro = re * sf / Math.pow(ro, sn);

    let ra = Math.tan(Math.PI * 0.25 + lat * DEGRAD * 0.5);
    ra = re * sf / Math.pow(ra, sn);
    let theta = lon * DEGRAD - olon;
    if (theta > Math.PI) theta -= 2.0 * Math.PI;
    if (theta < -Math.PI) theta += 2.0 * Math.PI;
    theta *= sn;

    const nx = Math.floor(ra * Math.sin(theta) + XO + 0.5);
    const ny = Math.floor(ro - ra * Math.cos(theta) + YO + 0.5);

    return { nx: nx, ny: ny };
}

