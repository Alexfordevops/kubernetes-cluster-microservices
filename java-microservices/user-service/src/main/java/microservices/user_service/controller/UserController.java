package microservices.user_service.controller;

import microservices.user_service.model.User;
import microservices.user_service.repository.UserRepository;
import microservices.user_service.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserRepository repository;

    @Autowired
    private JwtUtil jwtUtil;

    private boolean isAuthorized(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) return false;
        return jwtUtil.validateToken(authHeader.substring(7));
    }

    @GetMapping
    public ResponseEntity<?> findAll(@RequestHeader(value = "Authorization", required = false) String token) {
        if (!isAuthorized(token)) return ResponseEntity.status(401).build();
        return ResponseEntity.ok(repository.findAll());
    }

    @PostMapping
    public ResponseEntity<?> save(@RequestBody User user,
                                  @RequestHeader(value = "Authorization", required = false) String token) {
        if (!isAuthorized(token)) return ResponseEntity.status(401).build();
        return ResponseEntity.ok(repository.save(user));
    }
}
