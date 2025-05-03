
import java.io.*;
import java.net.InetAddress;
public class NetworkService extends Thread{
	String script = "/home/vm1/Network.sh";
	InetAddress client1IP;
	InetAddress client2IP;
	BufferedReader terminalReader = null;
	
	public NetworkService(InetAddress client1IP,InetAddress client2IP) {
		super();
		this.client1IP = client1IP;
		this.client2IP = client2IP;
		
	}
	
	public void run()
	{
		try {
			ProcessBuilder processBuilder = new ProcessBuilder("bash",script,client1IP.getHostAddress(),client2IP.getHostAddress());
			processBuilder.redirectErrorStream(true); // Combine standard error and output streams
			Process NetwrokTest = processBuilder.start();

			terminalReader = new  BufferedReader(new InputStreamReader (NetwrokTest.getInputStream()));
			
			String terminaloutput = terminalReader.readLine();
			while ( terminaloutput!= null){
				System.out.println(terminaloutput);
				terminaloutput = terminalReader.readLine();
			}
			NetwrokTest.waitFor();
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
				try {
					if(terminalReader !=null)
					terminalReader.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			
		}//end of finally
		
	}//end of run
	

}