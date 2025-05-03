import java.io.*;
import java.net.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ClientHandler extends Thread {
    private Socket clientSocket;
    private String clientName;
    private static final DateTimeFormatter TIMESTAMP_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public ClientHandler(Socket socket) {
        this.clientSocket = socket;
    }

    @Override
    public void run() {
        try {
            BufferedReader from_client = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            PrintWriter to_client = new PrintWriter(clientSocket.getOutputStream(), true);

            String input;
            while ((input = from_client.readLine()) != null) {
                try {
                    String[] parts = input.split(";");
                    if (parts[0].equals("REQUEST_TASK") && parts.length == 4) {
                        clientName = parts[2];
                        int serviceNumber = Integer.parseInt(parts[1]);
                        int priority = Integer.parseInt(parts[3]);
                        String response = Server.addTask(serviceNumber, clientName, priority, clientSocket);
                        to_client.println(response);
                    } else if (parts[0].equals("QUEUE_STATUS")) {
                        String response = Server.getQueueStatus();
                        to_client.println(response);
                    } else if (parts[0].equals("CANCEL_TASK") && parts.length == 3) {
                        if (clientName == null) {
                            to_client.println("REJECTED;" + LocalDateTime.now().format(TIMESTAMP_FORMATTER) + ";Client name not set.");
                            continue;
                        }
                        int taskId = Integer.parseInt(parts[1]);
                        String response = Server.cancelTask(taskId, parts[2]);
                        to_client.println(response);
                    } else if (parts[0].equals("TASK_HISTORY")) {
                        String response = Server.getTaskHistory();
                        to_client.println(response);
                    } else {
                        to_client.println("REJECTED;" + LocalDateTime.now().format(TIMESTAMP_FORMATTER) + ";Invalid command.");
                    }
                } catch (NumberFormatException | ArrayIndexOutOfBoundsException e) {
                    to_client.println("REJECTED;" + LocalDateTime.now().format(TIMESTAMP_FORMATTER) + ";Invalid command format.");
                }
            }
        } catch (IOException e) {
            System.out.println("Error handling client: " + e.getMessage());
        } finally {
            try {
                clientSocket.close();
            } catch (IOException e) {
                System.out.println("Error closing client socket: " + e.getMessage());
            }
        }
    }
}