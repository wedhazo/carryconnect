package com.carryconnect.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userId;

    @Column(nullable = false, length = 120,name="full_name")
    private String fullName;

    @Column(unique = true, length = 150)
    private String email;

    @Column(length = 50)
    private String phone;

    @Column(nullable = false,name="password_hash")
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "role")
    private UserRole role;

    @Column(name = "verified")
    private boolean verified;

    @Enumerated(EnumType.STRING)
    @Column(name = "contact_preferred")
    private ContactPreferred contactPreferred;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
