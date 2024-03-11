package com.example.first.example;

import java.util.List;

import com.example.first.example.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path="/todo")
public class UserController {

    @Autowired
    UserRepository userRepository;

    @GetMapping
    public String check() {
        return "Welcome to eunji api-server!";
    }

    @GetMapping(path="/todos")
    public List<String> getAllUsertodo() {
        return userRepository.getAllUsertodo();
    }
}