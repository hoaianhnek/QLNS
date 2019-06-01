package Interface;

import java.sql.Connection;
import java.sql.DriverManager;
import javax.swing.JOptionPane;


/**
 *
 * @author ASUS
 */

//create connection
public class DBConnect { 
    
    public static Connection connect()
    {
    Connection con = null;
         try {
            Class.forName("com.microsoft.sqlserver.jdbc.Driver");
                    String uRL="jdbc:sqlserver://Localhost:1433;databaseName=bookstore";
                    String user="sa";
                    String pass="dazzling911";
            con = DriverManager.getConnection(uRL,user,pass);
             JOptionPane.showMessageDialog(null,"Kết nối thành công");
            
        } catch (Exception e) {
                JOptionPane.showMessageDialog(null,"Không kết nối dữ liệu được\n"+e);
        }
        return con;
    }
}
