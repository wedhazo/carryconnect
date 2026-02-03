package com.carryconnect.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "packages")
public class PackagePost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="package_id")
    private Long packageId;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name="pickup_city")
    private String pickupCity;

    @Column(name="dropoff_city")
    private String dropoffCity;

    @Column(name="item_type")
    private String itemType;

    @Column(name="weight_kg")
    private Double weightKg;

    @Column(name="budget_amount")
    private Double budgetAmount;

    private boolean urgent;

    @Column(name="contact_info")
    private String contactInfo;

    @Column(columnDefinition = "TEXT")
    private String description;

    private boolean paidListing;

    private boolean boosted;

    @Enumerated(EnumType.STRING)
    @Column(name="post_status")
    private PostStatus postStatus;

    @Column(name="expiry_date")
    private LocalDate expiryDate;

    @Column(name="created_at")
    private LocalDateTime createdAt;

    @Column(name="update_at")
    private LocalDateTime updatedAt;

}
