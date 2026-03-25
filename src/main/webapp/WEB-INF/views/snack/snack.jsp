<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%
String ctxPath = request.getContextPath();
String userLevel = "";
String empId = "";
Object member = session.getAttribute("member");
if (member != null) {
	try {
		userLevel = String.valueOf(member.getClass().getMethod("getUserLevel").invoke(member));
		empId = String.valueOf(member.getClass().getMethod("getEmpId").invoke(member));
	} catch (Exception e) { /* ignore */ }
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC - 탕비실 신청</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<style>
/* --- 1. 기본 레이아웃 (유지) --- */
#main-content { 
    margin-left: 240px !important; 
    padding: 28px 32px !important; 
    box-sizing: border-box; 
    min-height: 100vh; 
    background: #f8f9fc; 
}

/* --- 2. 게시판 컨테이너 및 헤더 --- */
.snack-container { 
    background: #fff; 
    border-radius: 12px; 
    box-shadow: 0 2px 12px rgba(0,0,0,0.05); 
    padding: 24px; 
}
.snack-header { 
    display: flex; 
    align-items: center; 
    justify-content: space-between; 
    margin-bottom: 24px; 
}
.btn-request { 
    display: inline-flex; 
    align-items: center; 
    gap: 6px; 
    background: #4e73df; 
    color: #fff; 
    border: none; 
    border-radius: 8px; 
    padding: 10px 20px; 
    font-weight: 600; 
    cursor: pointer; 
    transition: background 0.2s;
}
.btn-request:hover { background: #2e59d9; }

/* --- 3. 리스트(테이블) 스타일 (최적화) --- */
.snack-table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
    margin-top: 10px;
}
.snack-table th {
    background: #f8f9fc;
    padding: 14px 12px;
    font-size: 13px;
    font-weight: 700;
    color: #4e5968;
    text-align: center;
    border-bottom: 2px solid #eef2f9;
}
.snack-table td {
    padding: 16px 12px;
    border-bottom: 1px solid #f0f2f9;
    font-size: 14px;
    color: #333;
    text-align: center;
}
.snack-table tr { transition: background 0.2s; cursor: pointer; }
.snack-table tr:hover { background: #fbfcfe; }

/* --- 4. 상태 뱃지 (결재 리스트 통일) --- */
.status-badge { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; white-space: nowrap; }
.status-PENDING  { background: #fff4e0; color: #d97706; }
.status-APPROVED { background: #e0f5ef; color: #1a9660; }
.status-REJECTED { background: #ffe0e0; color: #d93025; }

.vote-tag { display: inline-flex; align-items: center; gap: 4px; color: #4e73df; font-weight: 700; }
.comment-tag { display: inline-flex; align-items: center; gap: 4px; color: #9aa0b4; }
.vote-btn {
    display: inline-flex; align-items: center; gap: 6px;
    background: #f0f4ff; color: #4e73df;
    border: 1.5px solid #c7d4f8; border-radius: 20px;
    padding: 6px 16px; font-size: 13px; font-weight: 600;
    cursor: pointer; transition: all .15s;
}
.vote-btn:hover { background: #dce6ff; }
.vote-btn.voted { background: #4e73df; color: #fff; border-color: #4e73df; }
/* --- 5. 모달 레이어 (Portal 최적화 유지) --- */
.modal-overlay {
    position: fixed !important;
    top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important;
    width: 100vw !important; height: 100vh !important;
    background: rgba(0, 0, 0, 0.5) !important;
    z-index: 9999 !important;
    display: flex !important;
    align-items: center; justify-content: center;
}
.modal {
    background: #fff; border-radius: 16px; width: 550px; max-width: 95%;
    max-height: 90vh; overflow-y: auto; position: relative;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
    display: flex; flex-direction: column;
}
.modal-header { padding: 20px 24px; border-bottom: 1px solid #f0f2f9; display: flex; justify-content: space-between; align-items: center; }
.modal-body { padding: 24px; flex: 1; }
.modal-footer { padding: 16px 24px; border-top: 1px solid #f0f2f9; display: flex; justify-content: flex-end; gap: 8px; }

/* --- 6. 폼 및 기타 --- */
.form-row { margin-bottom: 16px; }
.form-row label { display: block; font-size: 13px; font-weight: 700; margin-bottom: 6px; color: #4e5968; }
.form-row input, .form-row textarea { 
    width: 100%; padding: 12px; border: 1px solid #d8dde6; border-radius: 8px; box-sizing: border-box; 
    font-size: 14px;
}
.comment-item { background: #f8f9fc; border-radius: 8px; padding: 12px; margin-top: 8px; font-size: 13px; }

/* --- 7. 페이지네이션 (결재 리스트 통일) --- */
.table-pagination { display: flex; justify-content: center; align-items: center; gap: 6px; padding: 16px; border-top: 1px solid #f0f2f9; }
.page-btn { background: none; border: 1px solid #e6eaf4; border-radius: 5px; padding: 5px 10px; font-size: 12px; color: #7b82a0; cursor: pointer; transition: all .15s; }
.page-btn:hover { background: #f0f3ff; border-color: #4e73df; color: #4e73df; }
.page-btn.active { background: #4e73df; border-color: #4e73df; color: #fff; font-weight: 700; }
.page-btn:disabled { opacity: .4; cursor: default; }
</style>
</head>
<body>

	<jsp:include page="/WEB-INF/views/layout/header.jsp" />
	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<main id="main-content">
		<div id="snack-root"></div>
	</main>

	<script src="https://unpkg.com/react@18/umd/react.development.js"></script>
	<script src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
	<script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>

	<script>
        /* JSP 변수 할당 에러 수정 */
        var SNACK_CTX      = '<%= request.getContextPath() %>';
		var SNACK_IS_ADMIN = <%= "99".equals(userLevel) %>;
		var SNACK_EMP_ID   = '<%= (empId != null) ? empId.trim() : "" %>'; 
	</script>

	<script type="text/babel">
const { useState, useEffect, useCallback } = React;
const { createPortal } = ReactDOM;

const statusLabel = s => ({ PENDING: '대기중', APPROVED: '승인', REJECTED: '반려' }[s] || s);

/* 1. 신청 폼 모달 (Portal 방식) */
function FormModal({ onClose, onSubmit }) {
    const [form, setForm] = useState({ itemName: '', quantity: 1, reason: '' });

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await fetch(`\${SNACK_CTX}/api/snack`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(form)
            });
            if (res.ok) {
                alert('신청되었습니다.');
                onSubmit();
            }
        } catch (err) { console.error(err); }
    };

    return createPortal(
        <div className="modal-overlay">
            <div className="modal">
                <div className="modal-header">
                    <h3 style={{margin:0}}>비품 신청하기</h3>
                    <button onClick={onClose} style={{background:'none', border:'none', cursor:'pointer'}}>
                        <span className="material-symbols-outlined">close</span>
                    </button>
                </div>
                <form onSubmit={handleSubmit}>
                    <div className="modal-body">
                        <div className="form-row">
                            <label>품목명</label>
                            <input autoFocus value={form.itemName} onChange={e => setForm({...form, itemName: e.target.value})} required placeholder="예: 아메리카노 캡슐" />
                        </div>
                        <div className="form-row">
                            <label>수량</label>
                            <input type="number" min="1" value={form.quantity} onChange={e => setForm({...form, quantity: e.target.value})} />
                        </div>
                        <div className="form-row">
                            <label>신청 이유</label>
                            <textarea value={form.reason} onChange={e => setForm({...form, reason: e.target.value})} required style={{height:'100px'}} />
                        </div>
                    </div>
                    <div className="modal-footer">
                        <button type="button" onClick={onClose} style={{padding:'8px 16px', border:'none', borderRadius:'6px', cursor:'pointer'}}>취소</button>
                        <button type="submit" style={{padding:'8px 16px', background:'#4e73df', color:'#fff', border:'none', borderRadius:'6px', cursor:'pointer'}}>신청하기</button>
                    </div>
                </form>
            </div>
        </div>,
        document.body
    );
}

/* 2. 상세 보기 모달 (Portal 방식) */
function DetailModal({ snackId, onClose, onRefresh }) {
    const [detail, setDetail] = useState(null);
    const [newComment, setNewComment] = useState('');
    const [loading, setLoading] = useState(true);

    const load = useCallback(async () => {
    try {
        setLoading(true);
        const url = `\${SNACK_CTX}/api/snack/\${snackId}`.replace(/\/+/g, '/');
        const res = await fetch(url);

        if (!res.ok) {
            throw new Error('데이터를 불러오지 못했습니다.');
        }

        const text = await res.text();
        if (text.includes("<!DOCTYPE")) {
        
            return;
        }

        const data = JSON.parse(text);
        setDetail(data);
    } catch (err) {
        onClose();
    } finally {
        setLoading(false);
    }
}, [snackId, onClose]);

    useEffect(() => { load(); }, [load]);

    const [adminComment, setAdminComment] = useState('');

    const updateStatus = async (newStatus) => {
        if (newStatus === 'REJECTED' && !adminComment.trim()) {
            alert('반려 사유를 입력해주세요.');
            return;
        }
        if (!confirm(newStatus === 'APPROVED' ? '승인하시겠습니까?' : '반려하시겠습니까?')) return;
        try {
            const res = await fetch(`\${SNACK_CTX}/api/snack/\${snackId}/status`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ status: newStatus, adminComment: adminComment })
            });
            if (res.ok) {
                alert(newStatus === 'APPROVED' ? '승인되었습니다.' : '반려되었습니다.');
                onRefresh();
                load();
            }
        } catch (err) { console.error(err); }
    };

    const toggleVote = async () => {
        try {
            await fetch(`\${SNACK_CTX}/api/snack/\${snackId}/vote`, { method: 'POST' });
            load();
        } catch (err) { console.error(err); }
    };

    const submitComment = async () => {
        if (!newComment.trim()) return;
        try {
            await fetch(`\${SNACK_CTX}/api/snack/\${snackId}/comment`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ content: newComment })
            });
            setNewComment('');
            load();
        } catch (err) { console.error(err); }
    };

    if (loading) return null;
    if (!detail) return null;

    return createPortal(
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal" onClick={e => e.stopPropagation()}>
                <div className="modal-header">
                    <h3 style={{margin:0}}>신청 상세 보기</h3>
                    <button onClick={onClose} style={{background:'none', border:'none', cursor:'pointer', display:'flex'}}>
                        <span className="material-symbols-outlined">close</span>
                    </button>
                </div>
                <div className="modal-body">
                    <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom:'16px'}}>
                        <span style={{fontWeight:700, fontSize:'16px'}}>{detail.itemName}</span>
                        <span className={`status-badge status-\${detail.status}`}>{statusLabel(detail.status)}</span>
                    </div>
                    <div style={{fontSize:'13px', color:'#667085', marginBottom:'8px'}}>수량: {detail.quantity}개</div>
                    <div style={{fontSize:'13px', color:'#667085', marginBottom:'8px'}}>신청자: {detail.requesterName}</div>
                    <div style={{fontSize:'13px', color:'#667085', marginBottom:'16px'}}>신청일: {detail.regDate}</div>
                    <div style={{background:'#f8f9fc', borderRadius:'8px', padding:'14px', marginBottom:'16px', fontSize:'14px', lineHeight:'1.6'}}>
                        {detail.reason}
                    </div>

                    {detail.adminComment && (
                        <div style={{background:'#fff8f0', borderRadius:'8px', padding:'14px', marginBottom:'16px', fontSize:'13px', border:'1px solid #fde4c8'}}>
                            <strong>관리자 의견:</strong> {detail.adminComment}
                        </div>
                    )}

                    {SNACK_IS_ADMIN && detail.status === 'PENDING' && (
                        <div style={{background:'#f0f4ff', borderRadius:'8px', padding:'16px', marginBottom:'16px', border:'1px solid #d0d9f0'}}>
                            <h4 style={{margin:'0 0 10px', fontSize:'14px', color:'#4e5968'}}>관리자 처리</h4>
                            <textarea
                                value={adminComment}
                                onChange={e => setAdminComment(e.target.value)}
                                placeholder="승인/반려 사유를 입력하세요 (반려 시 필수)"
                                style={{width:'100%', padding:'10px', border:'1px solid #d8dde6', borderRadius:'8px', height:'70px', boxSizing:'border-box', marginBottom:'10px'}}
                            />
                            <div style={{display:'flex', gap:'8px', justifyContent:'flex-end'}}>
                                <button onClick={() => updateStatus('APPROVED')} style={{padding:'8px 20px', background:'#059669', color:'#fff', border:'none', borderRadius:'6px', cursor:'pointer', fontWeight:600}}>승인</button>
                                <button onClick={() => updateStatus('REJECTED')} style={{padding:'8px 20px', background:'#dc2626', color:'#fff', border:'none', borderRadius:'6px', cursor:'pointer', fontWeight:600}}>반려</button>
                            </div>
                        </div>
                    )}

                    <div style={{display:'flex', alignItems:'center', gap:'12px', marginBottom:'20px'}}>
                        <button className={`vote-btn\${detail.voted ? ' voted' : ''}`} onClick={toggleVote}>
                            <span className="material-symbols-outlined" style={{fontSize:'16px'}}>thumb_up</span>
                            공감 {detail.voteCount}
                        </button>
                    </div>

                    <div style={{borderTop:'1px solid #f0f2f9', paddingTop:'16px'}}>
                        <h4 style={{margin:'0 0 12px', fontSize:'14px'}}>댓글 ({detail.comments ? detail.comments.length : 0})</h4>
                        {detail.comments && detail.comments.map(c => (
                            <div key={c.commentId} className="comment-item">
                                <div style={{display:'flex', justifyContent:'space-between', marginBottom:'4px'}}>
                                    <strong style={{fontSize:'12px'}}>{c.authorName}</strong>
                                    <span style={{fontSize:'11px', color:'#9aa0b4'}}>{c.regDate}</span>
                                </div>
                                <div>{c.content}</div>
                            </div>
                        ))}
                        <div style={{display:'flex', gap:'8px', marginTop:'12px'}}>
                            <input
                                value={newComment}
                                onChange={e => setNewComment(e.target.value)}
                                onKeyDown={e => e.key === 'Enter' && submitComment()}
                                placeholder="댓글을 입력하세요"
                                style={{flex:1, padding:'10px', border:'1px solid #d8dde6', borderRadius:'8px'}}
                            />
                            <button onClick={submitComment} style={{padding:'10px 16px', background:'#4e73df', color:'#fff', border:'none', borderRadius:'8px', cursor:'pointer', whiteSpace:'nowrap'}}>등록</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>,
        document.body
    );
}

/* 3. 메인 앱 컴포넌트 */
function SnackApp() {
    const [list, setList] = useState([]);
    const [selectedId, setSelectedId] = useState(null);
    const [showForm, setShowForm] = useState(false);
    const [pageNo, setPageNo] = useState(1);
    const [totalCount, setTotalCount] = useState(0);
    const pageSize = 10;
    const totalPages = Math.ceil(totalCount / pageSize) || 1;

    // 이미지 2, 4번의 HTML 반환 에러 방지를 위한 fetch 로직
    const fetchList = useCallback(async (page) => {
        const p = page || pageNo;
        try {
            const response = await fetch(`\${SNACK_CTX}/api/snack/list?pageNo=\${p}&pageSize=\${pageSize}`);
            const text = await response.text();

            // HTML이 반환되었는지 체크 (로그인 만료 등)
            if (text.trim().startsWith("<!DOCTYPE")) {
                console.error("API 경로가 잘못되었거나 서버 에러 페이지가 반환되었습니다.");
                return;
            }

            const data = JSON.parse(text);
            setList(data.list || []);
            setTotalCount(data.total || 0);
        } catch (e) {
            console.error("데이터 로딩 실패:", e);
        }
    }, [pageNo]);

    const changePage = (p) => {
        if (p < 1 || p > totalPages || p === pageNo) return;
        setPageNo(p);
        fetchList(p);
    };

    useEffect(() => { fetchList(); }, [fetchList]);

    return (
        <div className="snack-container">
            <div className="snack-header">
                <div>
                    <h2 style={{margin:0, fontSize:'22px', color:'#1a1f36'}}>탕비실 비품 신청</h2>
                    <p style={{margin:'4px 0 0', color:'#697386'}}>필요한 비품을 신청하고 동료들의 공감을 확인하세요.</p>
                </div>
                <button className="btn-request" onClick={() => setShowForm(true)}>
                    <span className="material-symbols-outlined" style={{fontSize:'18px'}}>add</span>
                    신청하기
                </button>
            </div>

            <table className="snack-table">
                <thead>
                    <tr>
                        <th style={{width:'80px'}}>번호</th>
                        <th>제목</th>
                        <th style={{width:'120px'}}>신청자</th>
                        <th style={{width:'120px'}}>상태</th>
                        <th style={{width:'100px'}}>공감</th>
                        <th style={{width:'100px'}}>댓글</th>
                    </tr>
                </thead>
                <tbody>
                    {list.length > 0 ? list.map(item => (
                        <tr key={item.snackId} onClick={() => setSelectedId(item.snackId)}>
                            <td>{item.snackId}</td>
                            <td style={{textAlign:'left', paddingLeft:'20px'}}>
                                <strong>{item.itemName}</strong>
                            </td>
                            <td>{item.requesterName}</td>
                            <td>
                                <span className={`status-badge status-\${item.status}`}>
                                    {statusLabel(item.status)}
                                </span>
                            </td>
                            <td>
                                <span className={`vote-tag \${item.voted ? 'voted' : ''}`}>
                                    <span className="material-symbols-outlined" style={{fontSize:'16px'}}>thumb_up</span>
                                    {item.voteCount}
                                </span>
                            </td>
                            <td style={{color:'#9aa0b4'}}>
                                <span className="material-symbols-outlined" style={{fontSize:'16px', verticalAlign:'middle'}}>chat_bubble</span>
                                {item.commentCount || 0}
                            </td>
                        </tr>
                    )) : (
                        <tr>
                            <td colSpan="6" style={{padding:'100px 0', color:'#9aa0b4'}}>신청 내역이 없습니다.</td>
                        </tr>
                    )}
                </tbody>
            </table>

            {/* 페이지네이션 */}
            <div className="table-pagination">
                <button className="page-btn" disabled={pageNo <= 1} onClick={() => changePage(1)}>&laquo; 처음</button>
                <button className="page-btn" disabled={pageNo <= 1} onClick={() => changePage(pageNo - 1)}>&lsaquo; 이전</button>
                {Array.from({ length: totalPages }, (_, i) => i + 1).map(p => (
                    <button key={p} className={`page-btn\${p === pageNo ? ' active' : ''}`} onClick={() => changePage(p)}>{p}</button>
                ))}
                <button className="page-btn" disabled={pageNo >= totalPages} onClick={() => changePage(pageNo + 1)}>다음 &rsaquo;</button>
                <button className="page-btn" disabled={pageNo >= totalPages} onClick={() => changePage(totalPages)}>마지막 &raquo;</button>
            </div>

            {/* 모달 컴포넌트 연결 */}
            {selectedId && <DetailModal snackId={selectedId} onClose={() => setSelectedId(null)} onRefresh={fetchList} />}
            {showForm && <FormModal onClose={() => setShowForm(false)} onSubmit={() => { setShowForm(false); fetchList(); }} />}
        </div>
    );
}

const root = ReactDOM.createRoot(document.getElementById('snack-root'));
root.render(<SnackApp />);
</script>
</body>
</html>