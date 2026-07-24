import { useEffect, useState } from "react";

const API_URL = "/api/todos";

export default function App() {
  const [todos, setTodos] = useState([]);
  const [title, setTitle] = useState("");
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  async function loadTodos() {
    setLoading(true);
    setError("");

    try {
      const response = await fetch(API_URL);
      if (!response.ok) {
        throw new Error("Failed to load todos");
      }

      const data = await response.json();
      setTodos(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadTodos();
  }, []);

  async function handleSubmit(event) {
    event.preventDefault();
    const trimmedTitle = title.trim();

    if (!trimmedTitle) {
      return;
    }

    setSubmitting(true);
    setError("");

    try {
      const response = await fetch(API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ title: trimmedTitle })
      });

      if (!response.ok) {
        throw new Error("Failed to create todo");
      }

      const createdTodo = await response.json();
      setTodos((currentTodos) => [createdTodo, ...currentTodos]);
      setTitle("");
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(id) {
    setError("");

    try {
      const response = await fetch(`${API_URL}/${id}`, {
        method: "DELETE"
      });

      if (!response.ok) {
        throw new Error("Failed to delete todo");
      }

      setTodos((currentTodos) => currentTodos.filter((todo) => todo.id !== id));
    } catch (err) {
      setError(err.message);
    }
  }

  return (
    <main className="app-shell">
      <section className="card">
        <div className="hero">
          <p className="eyebrow">React + Nginx</p>
          <h1>Todo Project</h1>
          <p className="subtitle">Frontend talks to Spring Boot through the same origin.</p>
        </div>

        <form className="todo-form" onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="Add a new todo"
            value={title}
            onChange={(event) => setTitle(event.target.value)}
            disabled={submitting}
          />
          <button type="submit" disabled={submitting}>
            {submitting ? "Saving..." : "Add"}
          </button>
        </form>

        {error ? <p className="message error">{error}</p> : null}
        {loading ? <p className="message">Loading todos...</p> : null}

        {!loading && todos.length === 0 ? (
          <p className="message">No todos yet. Create the first one.</p>
        ) : null}

        <ul className="todo-list">
          {todos.map((todo) => (
            <li key={todo.id} className="todo-item">
              <div>
                <strong>{todo.title}</strong>
                <p>
                  {todo.completed ? "Completed" : "Pending"} •{" "}
                  {new Date(todo.createdAt).toLocaleString()}
                </p>
              </div>
              <button type="button" className="delete-button" onClick={() => handleDelete(todo.id)}>
                Delete
              </button>
            </li>
          ))}
        </ul>
      </section>
    </main>
  );
}
