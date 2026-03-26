const { useState, useEffect, useCallback } = React;
const ctx       = document.querySelector('meta[name="ctx"]').content;
const IS_ADMIN  = document.querySelector('meta[name="isAdmin"]').content === '99';
const MY_EMP_ID = document.querySelector('meta[name="myEmpId"]').content;

const statusLabel = s => ({ PENDING: '대기중', APPROVED: '승인', REJECTED: '반려' }[s] || s);


function VoteBtn({ voted, count, onClick }) {
    return (
        <button className={`vote-btn${voted ? ' voted' : ''}`}
                onClick={e => { e.stopPropagation(); onClick(); }}>
            ❤ {count}
        </button>
    );
}


function StatusBadge({ status }) {
    return <span className={`status-badge status-${status}`}>{statusLabel(status)}</span>;
}


function SnackRow({ item, onVote, onOpen }) {
    return (
        <tr onClick={() => onOpen(item.snackId)} style={{cursor:'pointer'}}>
            <td>{item.snackId}</td>
            <td>{item.itemName}</td>
            <td>{item.quantity}</td>
            <td>{item.requesterName}</td>
            <td>{item.regDate}</td>

            <td onClick={e => e.stopPropagation()}>
                <VoteBtn
                    voted={item.voted}
                    count={item.voteCount}
                    onClick={() => onVote(item)}
                />
            </td>

            <td>{item.commentCount || (item.comments ? item.comments.length : 0)}</td>

            <td>
                <StatusBadge status={item.status} />
            </td>
        </tr>
    );
}


function DetailModal({ snackId, onClose, onRefresh }) {
    const [detail, setDetail] = useState(null);
    const [newComment, setNewComment] = useState('');

    const load = useCallback(async () => {
        const res = await fetch(`${ctx}/api/snack/${snackId}`);
        const data = await res.json();
        setDetail(data);
    }, [snackId]);

    useEffect(() => { load(); }, [load]);

    if (!detail) return <div className="modal">로딩중...</div>;

    const toggleVote = async () => {
        const res = await fetch(`${ctx}/api/snack/${snackId}/vote`, { method: 'POST' });
        const data = await res.json();
        setDetail(p => ({ ...p, voteCount: data.voteCount, voted: !p.voted }));
        onRefresh();
    };

    const submitComment = async () => {
        if (!newComment.trim()) return;
        await fetch(`${ctx}/api/snack/${snackId}/comment`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ content: newComment })
        });
        setNewComment('');
        load();
    };

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal" onClick={e => e.stopPropagation()}>
                <h3>{detail.itemName}</h3>
                <p>{detail.reason}</p>

                <VoteBtn voted={detail.voted} count={detail.voteCount} onClick={toggleVote} />

                <div>
                    <textarea value={newComment} onChange={e => setNewComment(e.target.value)} />
                    <button onClick={submitComment}>댓글 등록</button>
                </div>

                {detail.comments && detail.comments.map(c => (
                    <div key={c.commentId}>
                        <b>{c.authorName}</b> : {c.content}
                    </div>
                ))}
            </div>
        </div>
    );
}


function SnackApp() {
    const [list, setList] = useState([]);
    const [detailId, setDetailId] = useState(null);

    const fetchList = useCallback(async () => {
        const res = await fetch(`${ctx}/api/snack/list?pageNo=1&pageSize=20`);
        const data = await res.json();
        setList(data.list || []);
    }, []);

    useEffect(() => { fetchList(); }, [fetchList]);

    const toggleVote = async (item) => {
        const res = await fetch(`${ctx}/api/snack/${item.snackId}/vote`, { method: 'POST' });
        const data = await res.json();
        setList(prev => prev.map(i =>
            i.snackId === item.snackId ? { ...i, voteCount: data.voteCount, voted: !i.voted } : i
        ));
    };

    return (
        <div>
            <h2>탕비실 신청 게시판</h2>

			<table className="snack-table">
			    <thead>
			        <tr>
			            <th style={{width:'60px'}}>번호</th>
			            <th>품목명</th>
			            <th style={{width:'80px'}}>신청자</th>
			            <th style={{width:'100px'}}>상태</th>
			            <th style={{width:'80px'}}>공감</th>
			            <th style={{width:'80px'}}>댓글</th>
			        </tr>
			    </thead>
			    <tbody>
			        {list.length > 0 ? list.map(item => (
			            <tr key={item.snackId} onClick={() => setSelectedId(item.snackId)} style={{cursor:'pointer'}}>
			                <td style={{textAlign:'center'}}>{item.snackId}</td>
			                <td>{item.itemName}</td>
			                <td style={{textAlign:'center'}}>{item.requesterName}</td>
			                <td style={{textAlign:'center'}}>
			                    <span className={`status-badge status-${item.status}`}>
			                        {statusLabel(item.status)}
			                    </span>
			                </td>
			                <td style={{textAlign:'center'}}>👍 {item.voteCount}</td>
			                <td style={{textAlign:'center'}}>
			                    💬 {item.commentCount || 0}
			                </td>
			            </tr>
			        )) : (
			            <tr>
			                <td colSpan="6" style={{textAlign:'center', padding:'50px'}}>
			                    데이터 없음
			                </td>
			            </tr>
			        )}
			    </tbody>
			</table>

            {detailId && (
                <DetailModal
                    snackId={detailId}
                    onClose={() => setDetailId(null)}
                    onRefresh={fetchList}
                />
            )}
        </div>
    );
}

ReactDOM.createRoot(document.getElementById('snack-root')).render(<SnackApp />);
