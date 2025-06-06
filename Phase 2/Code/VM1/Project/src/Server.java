
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

public class Server {
    private static ArrayList<Socket> mySockets = new ArrayList<>();  
    public static void main(String args[]){
        
    try{
        
        ServerSocket server = new ServerSocket(1300);
        System.out.println(server.getInetAddress().getHostAddress());
        while(true){
            do{
                if (mySockets.size()<2)
                 System.out.println("We Need Two clients to connect");
                Socket Client = server.accept();
                mySockets.add(Client);
            }while(mySockets.size()<2);
            System.out.println("Testing the connection to both clients");
            NetworkService N1 = new NetworkService(mySockets.get(0).getInetAddress(),mySockets.get(1).getInetAddress());
            N1.start();
             for (Socket client: mySockets){
                client.close();
            }
            
        }
    }catch(IOException ioe){
        System.out.println("Error" + ioe);
    }
   
}}
