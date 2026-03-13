package com.mvc.app.notification.mapper;

import com.mvc.app.notification.entity.NotificationEntity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 알림 MyBatis Mapper
 */
@Mapper
public interface NotificationMapper {

    /** 알림 단건 INSERT */
    void insertNotification(NotificationEntity entity);

    /** 수신자 기준 알림 목록 조회 (최신 20건, 읽음 여부 무관) */
    List<NotificationEntity> selectByReceiverId(@Param("receiverId") String receiverId);

    /** 읽지 않은 알림 수 조회 */
    int countUnread(@Param("receiverId") String receiverId);

    /** 단건 읽음 처리 */
    void updateRead(@Param("notiId") Long notiId, @Param("receiverId") String receiverId);

    /** 전체 읽음 처리 */
    void updateReadAll(@Param("receiverId") String receiverId);
}
