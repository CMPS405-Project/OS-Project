import java.io.*;
import java.net.*;
import java.util.ArrayList;

public class NetworkServiceThread extends Thread {
    String script = "/home/vm1_server/CMPS405_Project/VM1_Server/Network.sh";
    InetAddress client1ip;
    InetAddress client2ip;
    BufferedReader terminalReader = null;
    private ArrayList<Socket> clientSockets;

    public NetworkServiceThread(InetAddress client1ip, InetAddress client2ip, ArrayList<Socket> sockets) {
        super();
        this.client1ip = client1ip;
        this.client2ip = client2ip;
        this.clientSockets = sockets;
    }

    public void run() {
        try {
            System.out.println("Starting NetworkService thread");
            System.out.println("Script path: " + script);
            System.out.println("Client1 IP: " + client1ip.getHostAddress());
            System.out.println("Client2 IP: " + client2ip.getHostAddress());

            ProcessBuilder processBuilder = new ProcessBuilder("bash", script, client1ip.getHostAddress(), client2ip.getHostAddress());
            processBuilder.redirectErrorStream(true);

            System.out.println("Executing shell script...");
            Process networkTest = processBuilder.start();

            terminalReader = new BufferedReader(new InputStreamReader(networkTest.getInputStream()));
            String terminalOutput;
            while ((terminalOutput = terminalReader.readLine()) != null) {
                System.out.println(terminalOutput);
            }

            System.out.println("Waiting for script to complete...");
            networkTest.waitFor();
            System.out.println("Network.sh script execution completed");

        } catch (Exception e) {
            System.out.println("Error in NetworkService:");
            e.printStackTrace();
        } finally {
            try {
                if (terminalReader != null)
                    terminalReader.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}