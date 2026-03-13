import axios from 'axios';

// Axios 인스턴스 생성(FormData를 보면 자동으로 multipart로 변경)
const http = axios.create({
    baseURL: '/api',
	// baseURL: '',
    timeout: 10000, // 10초 이상 응답 없으면 에러
    headers: {
        'Content-Type': 'application/json'
    },
});

// 요청 인터셉터(요청 전 공통 작업)
http.interceptors.request.use(
	(config) => {
		config.headers.AJAX = 'true';
        return config;
    },
    (error) => Promise.reject(error)
);

// 응답 인터셉터(응답 후 공통 에러 처리)
http.interceptors.response.use(
	(response) => response,
	(error) => {
		if (error.response && error.response.status === 401) {
			alert('세션이 만료되었습니다. 다시 로그인해주세요.');
		}
		return Promise.reject(error);
    }
);

export default http;