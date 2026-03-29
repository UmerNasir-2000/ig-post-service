package org.dometrain.igpostservice.post;

import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PostRepository extends JpaRepository<@NonNull Post, @NonNull Long> { }
