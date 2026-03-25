const { useState, useEffect, useCallback } = React;
const ctx       = document.querySelector('meta[name="ctx"]').content;
const IS_ADMIN  = document.querySelector('meta[name="isAdmin"]').content === '99';
const MY_EMP_ID = document.querySelector('meta[name="myEmpId"]').content;

const statusLabel = s => ({ PENDING: '대기중', APPROVED: '승인', REJECTED: '반려' }[s] || s);

/* ── 공감 버튼 ── */
function VoteBtn({ voted, count, onClick }) {
    return (
        <button className={`vote-btn${voted ? ' voted' : ''}`}
                onClick={e => { e.stopPropagation(); onClick(); }}>
            <span className="material-symbols-outlined">favorite</span>
            {count}
        </button>
    );
}

/* ── 상태 뱃지 ── */
function StatusBadge({ status }) {
    return <span className={`status-badge status-${status}`}>{statusLabel(status)}</span>;
}

/* ── 신청 카드 ── */
function SnackCard({ item, onVote, onOpen }) {
    return (
        <div className="snack-card" onClick={() => onOpen(item.snackId)}>
            <div className="card-top">
                <span className="item-name">{item.itemName}</span>
                <StatusBadge status={item.status} />
            </div>
            <div className="card-meta">수량 {item.quantity}개 · {item.regDate} · {item.requesterName}</div>
            <div className="card-reason">{item.reason}</div>
            <div className="card-footer">
                <VoteBtn voted={item.voted} count={item.voteCount} onClick={() => onVote(item)} />
                <span className="comment-count">
                    <span className="material-symbols-outlined">chat_bubble</span>
                    {item.commentCount || 0}
                </span>
                <span className="card-requester">{item.requesterName}</span>
            </div>
        </div>
    );
}

/* ── 신청 등록 모달 ── */
function FormModal({ onClose, onSubmit }) {
    const [form, setForm] = useState({ itemName: '', quantity: 1, reason: '' });
    const set = (k, v) => setForm(p => ({ ...p, [k]: v }));

    const submit = async () => {
        if (!form.itemName.trim()) { alert('품목명을 입력해주세요.'); return; }
        if (!form.reason.trim())   { alert('신청 이유를 입력해주세요.'); return; }
        const res = await fetch(`${ctx}/api/snack`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(form)
        });
        if (res.ok) { alert('신청이 등록되었습니다!'); onSubmit(); }
        else { alert('등록 실패'); }
    };

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal" onClick={e => e.stopPropagation()}>
                <div className="modal-header">
                    <h3>탕비실 비품 신청</h3>
                    <button className="modal-close" onClick={onClose}>
                        <span className="material-symbols-outlined">close</span>
                    </button>
                </div>
                <div className="modal-body">
                    <div className="form-row">
                        <label>품목명 <span style={{color:'#dc2626'}}>*</span></label>
                        <input value={form.itemName} onChange={e => set('itemName', e.target.value)}
                               placeholder="예: 허니버터칩, 아메리카노 캡슐" />
                    </div>
                    <div className="form-row">
                        <label>수량 <span style={{color:'#dc2626'}}>*</span></label>
                        <input type="number" min="1" value={form.quantity}
                               onChange={e => set('quantity', parseInt(e.target.value) || 1)} />
                    </div>
                    <div className="form-row">
                        <label>신청 이유 <span style={{color:'#dc2626'}}>*</span></label>
                        <textarea value={form.reason} onChange={e => set('reason', e.target.value)}
                                  placeholder="왜 필요한지 간단히 적어주세요!" />
                    </div>
                </div>
                <div className="modal-footer">
                    <button className="btn-cancel" onClick={onClose}>취소</button>
                    <button className="btn-save" onClick={submit}>신청하기</button>
                </div>
            </div>
        </div>
    );
}

/* ── 상세 모달 ── */
function DetailModal({ snackId, onClose, onRefresh }) {
    const [detail,       setDetail]       = useState(null);
    const [adminComment, setAdminComment] = useState('');
    const [newComment,   setNewComment]   = useState('');

    const load = useCallback(async () => {
        const res  = await fetch(`${ctx}/api/snack/${snackId}`);
        const data = await res.json();
        setDetail(data);
    }, [snackId]);

    useEffect(() => { load(); }, [load]);

    if (!detail) return (
        <div className="modal-overlay">
            <div className="modal" style={{padding:'40px', textAlign:'center', color:'#9aa0b4'}}>불러오는 중...</div>
        </div>
    );

    const toggleVote = async () => {
        const res  = await fetch(`${ctx}/api/snack/${snackId}/vote`, { method: 'POST' });
        const data = await res.json();
        setDetail(p => ({ ...p, voteCount: data.voteCount, voted: !p.voted }));
        onRefresh();
    };

    const processStatus = async (status) => {
        if (!confirm(status === 'APPROVED' ? '승인하시겠습니까?' : '반려하시겠습니까?')) return;
        const res = await fetch(`${ctx}/api/snack/${snackId}/status`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ status, adminComment })
        });
        if (res.ok) { alert(status === 'APPROVED' ? '승인되었습니다.' : '반려되었습니다.'); load(); onRefresh(); }
    };

    const deleteItem = async () => {
        if (!confirm('삭제하시겠습니까?')) return;
        const res = await fetch(`${ctx}/api/snack/${snackId}`, { method: 'DELETE' });
        if (res.ok) { alert('삭제되었습니다.'); onClose(); onRefresh(); }
    };

    const submitComment = async () => {
        if (!newComment.trim()) return;
        const res = await fetch(`${ctx}/api/snack/${snackId}/comment`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ content: newComment })
        });
        if (res.ok) { setNewComment(''); load(); onRefresh(); }
    };

    const deleteComment = async (commentId) => {
        if (!confirm('댓글을 삭제하시겠습니까?')) return;
        await fetch(`${ctx}/api/snack/comment/${commentId}`, { method: 'DELETE' });
        load();
    };

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal" onClick={e => e.stopPropagation()}>
                <div className="modal-header">
                    <h3>신청 상세</h3>
                    <button className="modal-close" onClick={onClose}>
                        <span className="material-symbols-outlined">close</span>
                    </button>
                </div>
                <div className="modal-body">
                    <div className="detail-item-name">
                        {detail.itemName}
                        <StatusBadge status={detail.status} />
                    </div>
                    <div className="detail-meta">
                        <span>수량: <b>{detail.quantity}개</b></span>
                        <span>신청자: <b>{detail.requesterName}</b></span>
                        <span>신청일: {detail.regDate}</span>
                        {detail.updateDate && <span>처리일: {detail.updateDate}</span>}
                    </div>
                    <div className="detail-reason">{detail.reason}</div>

                    {detail.adminComment && (
                        <div className={`admin-comment-box${detail.status === 'APPROVED' ? ' approved' : ''}`}>
                            <b>{detail.status === 'APPROVED' ? '✅ 승인' : '❌ 반려'} 사유:</b> {detail.adminComment}
                        </div>
                    )}

                    {IS_ADMIN && detail.status === 'PENDING' && (
                        <div className="admin-actions">
                            <h4>관리자 처리</h4>
                            <div className="form-row">
                                <label>처리 코멘트</label>
                                <input value={adminComment} onChange={e => setAdminComment(e.target.value)}
                                       placeholder="승인/반려 사유를 입력하세요" />
                            </div>
                            <div className="admin-btns">
                                <button className="btn-approve" onClick={() => processStatus('APPROVED')}>✅ 승인</button>
                                <button className="btn-reject"  onClick={() => processStatus('REJECTED')}>❌ 반려</button>
                            </div>
                        </div>
                    )}

                    <div style={{display:'flex', alignItems:'center', gap:'10px', marginBottom:'20px'}}>
                        <VoteBtn voted={detail.voted} count={detail.voteCount} onClick={toggleVote} />
                        {(IS_ADMIN || detail.requesterEmpId === MY_EMP_ID) && (
                            <button className="btn-delete-item" onClick={deleteItem}>삭제</button>
                        )}
                    </div>

                    <div className="comment-section">
                        <div className="comment-title">
                            댓글
                            <span className="comment-count-badge">{detail.comments ? detail.comments.length : 0}</span>
                        </div>
                        <div className="comment-write">
                            <textarea value={newComment} onChange={e => setNewComment(e.target.value)}
                                      onKeyDown={e => { if (e.ctrlKey && e.key === 'Enter') submitComment(); }}
                                      placeholder="댓글을 입력하세요... (Ctrl+Enter)" />
                            <button className="btn-comment" onClick={submitComment}>등록</button>
                        </div>
                        {detail.comments && detail.comments.length > 0
                            ? detail.comments.map(c => (
                                <div key={c.commentId} className="comment-item">
                                    <div className="comment-item-header">
                                        <span className="comment-author">{c.authorName}</span>
                                        <div style={{display:'flex', alignItems:'center', gap:'6px'}}>
                                            <span className="comment-date">{c.regDate}</span>
                                            {(IS_ADMIN || c.authorEmpId === MY_EMP_ID) && (
                                                <button className="btn-del-comment"
                                                        onClick={() => deleteComment(c.commentId)}>삭제</button>
                                            )}
                                        </div>
                                    </div>
                                    <div className="comment-text">{c.content}</div>
                                </div>
                            ))
                            : <div style={{textAlign:'center', padding:'20px', color:'#9aa0b4', fontSize:'13px'}}>
                                첫 번째 댓글을 남겨보세요!
                              </div>
                        }
                    </div>
                </div>
            </div>
        </div>
    );
}

/* ── 메인 앱 ── */
function SnackApp() {
    const [list,         setList]         = useState([]);
    const [total,        setTotal]        = useState(0);
    const [pageNo,       setPageNo]       = useState(1);
    const [keyword,      setKeyword]      = useState('');
    const [filterStatus, setFilterStatus] = useState('');
    const [showForm,     setShowForm]     = useState(false);
    const [detailId,     setDetailId]     = useState(null);
    const pageSize   = 12;
    const totalPages = Math.max(1, Math.ceil(total / pageSize));
    const pageRange  = (() => {
        const s = Math.max(1, pageNo - 2);
        const e = Math.min(totalPages, s + 4);
        return Array.from({ length: e - s + 1 }, (_, i) => s + i);
    })();

    const fetchList = useCallback(async (pNo, kw, st) => {
        const p = pNo !== undefined ? pNo : pageNo;
        const k = kw  !== undefined ? kw  : keyword;
        const s = st  !== undefined ? st  : filterStatus;
        const url = `${ctx}/api/snack/list?pageNo=${p}&pageSize=${pageSize}&keyword=${encodeURIComponent(k)}&status=${s}`;
        const res  = await fetch(url);
        const data = await res.json();
        setList(data.list  || []);
        setTotal(data.total || 0);
    }, [pageNo, keyword, filterStatus]);

	useEffect(() => {
	    fetchList();
	}, [fetchList]);

    const setFilter = (s) => { setFilterStatus(s); setPageNo(1); fetchList(1, keyword, s); };
    const changePage = (p) => { if (p < 1 || p > totalPages) return; setPageNo(p); fetchList(p, keyword, filterStatus); };
    const handleSearch = () => { setPageNo(1); fetchList(1, keyword, filterStatus); };

    const toggleVote = async (item) => {
        const res  = await fetch(`${ctx}/api/snack/${item.snackId}/vote`, { method: 'POST' });
        const data = await res.json();
        setList(prev => prev.map(i =>
            i.snackId === item.snackId ? { ...i, voteCount: data.voteCount, voted: !i.voted } : i
        ));
    };

    const filters = [['', '전체'], ['PENDING', '대기중'], ['APPROVED', '승인'], ['REJECTED', '반려']];

    return (
        <div>
            <div className="snack-header">
                <div className="snack-header-left">
                    <h2>
                        <span className="material-symbols-outlined" style={{color:'#4e73df'}}>local_cafe</span>
                        탕비실 신청
                    </h2>
                    <p>과자·음료 등 탕비실 비품을 신청하고 공감으로 우선순위를 높여보세요!</p>
                </div>
                <button className="btn-request" onClick={() => setShowForm(true)}>
                    <span className="material-symbols-outlined" style={{fontSize:'16px'}}>add</span>
                    신청하기
                </button>
            </div>

            <div className="filter-bar">
                <div className="filter-chips">
                    {filters.map(([val, label]) => (
                        <button key={val} className={`chip${filterStatus === val ? ' active' : ''}`}
                                onClick={() => setFilter(val)}>{label}</button>
                    ))}
                </div>
                <div className="search-box">
                    <span className="material-symbols-outlined" onClick={handleSearch}>search</span>
                    <input value={keyword} onChange={e => setKeyword(e.target.value)}
                           placeholder="품목명 또는 이유 검색"
                           onKeyDown={e => e.key === 'Enter' && handleSearch()} />
                </div>
            </div>

            {list.length > 0
                ? <div className="snack-grid">
                    {list.map(item => (
                        <SnackCard key={item.snackId} item={item}
                                   onVote={toggleVote}
                                   onOpen={id => setDetailId(id)} />
                    ))}
                  </div>
                : <div className="empty-state">
                    <span className="material-symbols-outlined">inventory_2</span>
                    등록된 신청이 없습니다.
                  </div>
            }

            {totalPages > 1 && (
                <div className="pagination">
                    <button className="page-btn" disabled={pageNo <= 1} onClick={() => changePage(1)}>&laquo;</button>
                    <button className="page-btn" disabled={pageNo <= 1} onClick={() => changePage(pageNo - 1)}>&lsaquo;</button>
                    {pageRange.map(p => (
                        <button key={p} className={`page-btn${p === pageNo ? ' active' : ''}`}
                                onClick={() => changePage(p)}>{p}</button>
                    ))}
                    <button className="page-btn" disabled={pageNo >= totalPages} onClick={() => changePage(pageNo + 1)}>&rsaquo;</button>
                    <button className="page-btn" disabled={pageNo >= totalPages} onClick={() => changePage(totalPages)}>&raquo;</button>
                </div>
            )}

            {showForm && (
                <FormModal
                    onClose={() => setShowForm(false)}
                    onSubmit={() => { setShowForm(false); fetchList(1, keyword, filterStatus); setPageNo(1); }}
                />
            )}

            {detailId && (
                <DetailModal
                    snackId={detailId}
                    onClose={() => setDetailId(null)}
                    onRefresh={() => fetchList(pageNo, keyword, filterStatus)}
                />
            )}
        </div>
    );
}

ReactDOM.createRoot(document.getElementById('snack-root')).render(<SnackApp />);
