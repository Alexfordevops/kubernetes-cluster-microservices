package microservices.product_service.controller;

import microservices.product_service.model.Product;
import microservices.product_service.repository.ProductRepository;
import microservices.product_service.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/products")
public class ProductController {

    @Autowired
    private ProductRepository repository;

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
    public ResponseEntity<?> save(@RequestBody Product product,
                                  @RequestHeader(value = "Authorization", required = false) String token) {
        if (!isAuthorized(token)) return ResponseEntity.status(401).build();
        return ResponseEntity.ok(repository.save(product));
    }
}
