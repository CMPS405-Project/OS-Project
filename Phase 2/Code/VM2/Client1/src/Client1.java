import java.io.*;
import java.net.Socket;
import java.util.*;
import java.util.concurrent.atomic.AtomicReference;

public class Client1 {
    private static final String CLIENT_NAME = "Client1";
    private static final String[] LOCAL_SCRIPTS = {"fix_perms.sh", "login_audit.sh"};
    private static final String SCRIPTS_DIR = "/home/vm2/CMPS405_Project/";
    private static final int[] SERVICE_NUMBERS = {2005};
//    private static final int[] SERVICE_NUMBERS = {2001, 2002, 2003, 2004, 2005};
    private static final Random random = new Random();
    private static final List<Integer> taskIds = new ArrayList<>();
    private static long lastRequestMillis = 0;
    private static final AtomicReference<Integer> currentTaskId = new AtomicReference<>(null);

    private enum RequestState {
        REQUEST_TASK, QUEUE_STATUS, TASK_HISTORY, CANCEL_TASK
    }

    public static void main(String[] args) {
        try (Socket socket = new Socket("192.168.6.128", 2500)) {
            System.out.println("Connected to server at 192.168.6.128:2500");
            BufferedReader fromServer = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter toServer = new PrintWriter(socket.getOutputStream(), true);
            runLocalScripts();
            new Thread(() -> handleServerInteractions(toServer, fromServer)).start();

            while (true) Thread.sleep(15000);
        } catch (IOException | InterruptedException e) {
            System.out.println("Error in Client1: " + e.getMessage());
        }
    }

    private static void handleServerInteractions(PrintWriter toServer, BufferedReader fromServer) {
        long lastQueueStatusTime = 0;
        long lastTaskHistoryTime = 0;
        long lastCancelTaskTime = 0;
        RequestState currentState = RequestState.REQUEST_TASK;
        boolean requestSent = false;

        while (true) {
            try {
                long currentTime = System.currentTimeMillis();

                if (!requestSent && (currentState != RequestState.REQUEST_TASK || currentTaskId.get() == null)) {
                    synchronized (toServer) {
                        String command = null;
                        switch (currentState) {
                            case REQUEST_TASK:
                                if (currentTime - lastRequestMillis >= 60000) {
                                    int serviceNumber = SERVICE_NUMBERS[random.nextInt(SERVICE_NUMBERS.length)];
                                    int priority = random.nextInt(3) + 1;
                                    command = String.format("REQUEST_TASK;%d;%s;%d", serviceNumber, CLIENT_NAME, priority);
                                    lastRequestMillis = currentTime;
                                }
                                break;
                            case QUEUE_STATUS:
                                if (currentTime - lastQueueStatusTime >= 300000) {
                                    command = "QUEUE_STATUS";
                                    lastQueueStatusTime = currentTime;
                                }
                                break;
                            case TASK_HISTORY:
                                if (currentTime - lastTaskHistoryTime >= 300000) {
                                    command = "TASK_HISTORY";
                                    lastTaskHistoryTime = currentTime;
                                }
                                break;
                            case CANCEL_TASK:
                                synchronized (taskIds) {
                                    if (currentTime - lastCancelTaskTime >= 600000 && !taskIds.isEmpty()) {
                                        int taskId = taskIds.get(random.nextInt(taskIds.size()));
                                        command = "CANCEL_TASK;" + taskId + ";" + CLIENT_NAME;
                                        lastCancelTaskTime = currentTime;
                                    }
                                }
                                break;
                        }

                        if (command != null) {
                            System.out.println("Sending automated request: " + command);
                            toServer.println(command);
                            requestSent = true;
                        } else {
                            currentState = getNextState(currentState);
                        }
                    }
                }

                String response;
                synchronized (fromServer) {
                    response = fromServer.ready() ? fromServer.readLine() : null;
                }

                if (response != null) {
                    Integer updatedTaskId = processServerResponse(response);
                    currentTaskId.set(updatedTaskId);
                    if (currentState != RequestState.REQUEST_TASK || currentTaskId.get() == null) {
                        currentState = getNextState(currentState);
                        requestSent = false;
                    }
                }

                Thread.sleep(1000);
            } catch (IOException | InterruptedException e) {
                System.out.println("Error during server interaction: " + e.getMessage());
                break;
            }
        }
    }

    private static Integer processServerResponse(String response) {
        System.out.println("Server response: " + response);
        String[] parts = response.split(";", 3);
        if (parts.length < 3) return currentTaskId.get();

        String status = parts[0];
        String message = parts[2];

        switch (status) {
            case "QUEUED":
                try {
                    int taskId = Integer.parseInt(message.split("ID ")[1]);
                    synchronized (taskIds) {
                        taskIds.add(taskId);
                    }
                    return taskId;
                } catch (Exception e) {
                    System.out.println("Failed to parse task ID: " + e.getMessage());
                }
                break;
            case "EXECUTING":
                System.out.println("Task is executing: " + message);
                break;
            case "COMPLETED":
            case "ERROR":
                System.out.println("Task finished: " + message);
                if (message.contains("TaskID") && message.contains("finished")) {
                    cleanupFinishedTask(message);
                }
                return null;
            case "REJECTED":
                System.out.println("Task rejected: " + message);
                return null;
        }
        return currentTaskId.get();
    }

    private static void cleanupFinishedTask(String message) {
        try {
            System.out.println("--------------------------------------");
            System.out.println(message);
            System.out.println("--------------------------------------");
            int taskId = Integer.parseInt(message.split("TaskID ")[1].split(" ")[0]);
            synchronized (taskIds) {
                taskIds.remove((Integer) taskId);
            }
        } catch (Exception e) {
            System.out.println("Failed to clean up task: " + e.getMessage());
        }
    }

    private static RequestState getNextState(RequestState state) {
        return switch (state) {
            case REQUEST_TASK -> RequestState.QUEUE_STATUS;
            case QUEUE_STATUS -> RequestState.TASK_HISTORY;
            case TASK_HISTORY -> RequestState.CANCEL_TASK;
            case CANCEL_TASK -> RequestState.REQUEST_TASK;
        };
    }

    private static void runLocalScripts() {
        for (String script : LOCAL_SCRIPTS) {
            try {
                System.out.println("Executing local script: " + script);
                ProcessBuilder pb;

                if (script.equals("login_audit.sh")) {
                    pb = new ProcessBuilder("bash", "-c", "echo 123 | sudo -S bash " + SCRIPTS_DIR + script);
                } else {
                    pb = new ProcessBuilder("bash", SCRIPTS_DIR + script);
                }

                pb.redirectErrorStream(true);
                Process p = pb.start();

                BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
                String line;
                while ((line = br.readLine()) != null) {
                    System.out.println(script + " output: " + line);
                }

                int exit = p.waitFor();
                System.out.println(script + " finished with exit code: " + exit);
            } catch (IOException | InterruptedException e) {
                System.out.println("Error: " + e.getMessage());
            }
        }
    }
}