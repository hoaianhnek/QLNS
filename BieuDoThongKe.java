/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Interface;

import Interface.ThongKe.QuanLyThongKeController;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.swing.JFrame;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.data.category.CategoryDataset;
import org.jfree.data.category.DefaultCategoryDataset;

/**
 *
 * @author ASUS
 */
public class BieuDoThongKe extends javax.swing.JInternalFrame {

    /**
     * Creates new form freechart
     */
    
    Connection conn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    
    public BieuDoThongKe() {
        initComponents();
        conn = DBConnect.connect();
 
        QuanLyThongKeController controller = new QuanLyThongKeController();
        controller.setDataToChart1(freechart);
    }  
    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        freechart = new javax.swing.JPanel();

        setClosable(true);
        setPreferredSize(new java.awt.Dimension(1070, 530));

        javax.swing.GroupLayout freechartLayout = new javax.swing.GroupLayout(freechart);
        freechart.setLayout(freechartLayout);
        freechartLayout.setHorizontalGroup(
            freechartLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 1036, Short.MAX_VALUE)
        );
        freechartLayout.setVerticalGroup(
            freechartLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 605, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(freechart, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(freechart, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents
       
           
            
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JPanel freechart;
    // End of variables declaration//GEN-END:variables
}
