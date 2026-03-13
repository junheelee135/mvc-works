package com.mvc.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class DepartmentDto {
    private String deptCode;        // 부서코드 (PK)
    private String deptName;        // 부서명
    private String extNo;           // 내선번호
    private String superDeptCode;   // 상위부서코드
    private String useYn;           // 사용여부
    private String regDate;         // 등록일

    private List<DepartmentDto> children; // 하위 부서 (트리 구성용)
}
