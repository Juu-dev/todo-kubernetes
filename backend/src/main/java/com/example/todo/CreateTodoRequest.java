package com.example.todo;

import jakarta.validation.constraints.NotBlank;

public record CreateTodoRequest(@NotBlank String title) {
}
