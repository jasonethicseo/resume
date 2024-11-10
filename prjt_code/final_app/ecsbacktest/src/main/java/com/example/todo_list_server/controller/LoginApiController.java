package com.example.todo_list_server.controller;

import com.example.todo_list_server.Mapper.UserMapper;
import com.example.todo_list_server.dto.Member;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

// 컨트롤러 레벨에 CORS 설정 추가

// @CrossOrigin(origins = "https://d2uo95yv1tnmpe.cloudfront.net", maxAge = 3600)  // 여기서 origins를 프론트엔드의 URL로 설정하세요.

@RestController
@RequestMapping("/api")
public class LoginApiController {

    @Autowired
    UserMapper userMapper;

    //생성자 생성(필수)
    @Autowired
    public LoginApiController(UserMapper userMapper) {
        this.userMapper = userMapper;
    }


    //회원가입
    @PostMapping("/signup")
    public String saveMember(@RequestBody Member member) {
        // 기존 회원이면 가입 안됨
        Member findMember = userMapper.findMember(member);
        if (findMember != null){
            return "이미 존재하는 회원입니다.";
        }

        userMapper.SignUp(member);

        return "success";
    }

    //로그인
    @PostMapping("/login")
    public String readMember(@RequestBody Member member, HttpServletRequest request, HttpServletResponse response) {

        String email = member.getEmail();
        String passwd = member.getPasswd();

        Member findMember = userMapper.findMember(member);
        if (findMember != null && findMember.getEmail().equals(email) && findMember.getPasswd().equals(passwd)) {
            HttpSession session = request.getSession(true); // 세션 생성
            session.setAttribute("member", findMember.getEmail());

            // 쿠키 생성
            String cookieStr = findMember.getNickname() + "_" + String.valueOf(findMember.getId());
            Cookie cookie = new Cookie("cookies", cookieStr);
            cookie.setMaxAge(24 * 60 * 60); // 쿠키 유효 시간 설정 (예: 1일)
            cookie.setPath("/"); // 쿠키의 유효 경로 설정 (루트로 설정하면 전체 애플리케이션에서 사용 가능)

            response.addCookie(cookie); // 응답에 쿠키 추가

            Member responseMember = new Member();
            responseMember.setId(findMember.getId());
            responseMember.setNickname(findMember.getNickname());
            return "success";
        }

        return "fail";
    }


    //로그아웃
    @GetMapping("/logout")
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession();
        session.invalidate();
        return "success";
    }
}
