package PriorityQueue;

import java.net.Socket;
import java.time.LocalDateTime;

public class Task implements Comparable<Task> {
    private int serviceNumber;
    private String scriptName;
    private String clientName;
    private int priority;
    private LocalDateTime timestamp;
    private int taskId;
    private Socket clientSocket;

    public Task(int serviceNumber, String scriptName, String clientName, int priority, int taskId, Socket clientSocket) {
        this.serviceNumber = serviceNumber;
        this.scriptName = scriptName;
        this.clientName = clientName;
        this.priority = priority;
        this.timestamp = LocalDateTime.now();
        this.taskId = taskId;
        this.clientSocket = clientSocket;
    }

    public int getServiceNumber() { return serviceNumber; }
    public String getScriptName() { return scriptName; }
    public String getClientName() { return clientName; }
    public int getPriority() { return priority; }
    public LocalDateTime getTimestamp() { return timestamp; }
    public int getTaskId() { return taskId; }
    public Socket getClientSocket() { return clientSocket; }

    @Override
    public int compareTo(Task other) {
        if (this.priority != other.priority) {
            return Integer.compare(this.priority, other.priority);
        }
        return this.timestamp.compareTo(other.timestamp);
    }

    @Override
    public String toString() {
        return "TaskID=" + taskId + ", Script=" + scriptName + ", Priority=" + priority + ", Client=" + clientName;
    }
}