package com.example.todo_list_server.Mapper;

import com.example.todo_list_server.dto.Member;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;

@Mapper
@Repository
public interface UserMapper {
    Member findMember(Member member);
    void SignUp(Member member);
}
