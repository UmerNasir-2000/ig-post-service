package org.dometrain.igpostservice.post;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import jakarta.persistence.*;

import org.hibernate.annotations.*;
import org.hibernate.generator.EventType;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "posts")
@Getter
@Setter
@SQLDelete(sql = "UPDATE posts SET deleted_at = CURRENT_TIMESTAMP WHERE post_id = ?")
@SQLRestriction("deleted_at IS NULL")
public class Post {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long postId;

    @Generated(event = EventType.INSERT)
    private UUID postUuid;

    private UUID fkUserUuid;

    @Column(nullable = false, length = 214)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT CHECK (char_length(caption) <= 2200)")
    private String caption;

    @Enumerated(EnumType.STRING)
    private Visibility visibility;

    /**
     * Denormalized column representing the total number of likes.
     */
    @Column(nullable = false, columnDefinition = "DEFAULT 0")
    private Integer likeCount;

    /**
     * Denormalized column representing the total number of comments.
     * This value is updated asynchronously via events produced by the CommentService.
     */
    @Column(nullable = false, columnDefinition = "DEFAULT 0")
    private Integer commentCount;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    /**
     * Timestamp used for soft deletion; if non-null, the post is considered deleted.
     */
    private LocalDateTime deletedAt;
}
