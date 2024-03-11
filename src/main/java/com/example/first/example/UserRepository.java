package com.example.first.example;


import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
@Repository
public class UserRepository {

    @Autowired
    JdbcTemplate jdbcTemplate;

    public List<String> getAllUsertodo() {
        List<String> usertodo = new ArrayList<>();
        List<Map<String, Object>> rows = jdbcTemplate.queryForList("SELECT * FROM todo");

        for (Map<String, Object> row : rows) {
            String title = (String) row.get("title");
            String body = (String) row.get("body");
            Date date = (Date) row.get("date");
            usertodo.add("Title: " + title + ", Body: " + body + ", Date: " + date);
        }
        return  usertodo;
    }
}
