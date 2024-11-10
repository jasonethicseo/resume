package com.example.todo_list_server.controller;

import com.example.todo_list_server.Mapper.TodoMapper;
import com.example.todo_list_server.dto.RequestTodo;

import com.example.todo_list_server.dto.ResponseTodo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

// 컨트롤러 레벨에 CORS 설정 추가

// @CrossOrigin(origins = "https://d2uo95yv1tnmpe.cloudfront.net", maxAge = 3600)  // 여기서 origins를 프론트엔드의 URL로 설정하세요.

@RestController
@RequestMapping("/api/todos")
public class TodoApiController {

    // REST API 표준 준수해서 만들기
    // { } - json
    // vue로 보내면 됌


    // /api/todos - GET 조회 (전체)
    // /api/todos - POST 등록
    // /api/todos/{id} - PUT 업데이트
    // /api/todos/{id} - DELETE 삭제
    // /api/todos/2


    @Autowired
    TodoMapper todoMapper;

    //생성자 생성(필수)
    @Autowired
    public TodoApiController(TodoMapper todoMapper) {
        this.todoMapper = todoMapper;
    }

    //등록
    @PostMapping("")
    public void save(@RequestBody RequestTodo todo) {
        System.out.println(todo);
        todoMapper.addTodo(todo);
    }

    //수정
    @PutMapping("/{id}")
    public int update(@PathVariable long id, @RequestBody RequestTodo requestTodo) {

        requestTodo.setMemberId(id);

        return todoMapper.TodoUpdate(requestTodo);
    }

    //조회 (내용)
    @GetMapping("")
    public ArrayList<ResponseTodo> readAll() {
//        System.out.println(todoMapper.getAllContent());
        return todoMapper.getAllContent();
    }

    //특정 조회
    @GetMapping("/{memberId}")
    public ArrayList<ResponseTodo> read(@PathVariable long memberId) {
        System.out.println("GET memberId " + memberId);
        ArrayList<ResponseTodo> findTodos = todoMapper.getById(memberId);

        return findTodos;
    }

    //삭제
    @DeleteMapping("/{id}")
    public void delete(@PathVariable long id) {
        todoMapper.TodoDelete(id);
    }

}
