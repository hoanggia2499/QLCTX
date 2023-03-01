using QuanLyChoThueXe.DTO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuanLyChoThueXe.DAO
{
 public class TableCarDAO
    {
        private static TableCarDAO instance;

        internal static TableCarDAO Instance
        {
            get { if (instance == null) instance = new TableCarDAO(); return TableCarDAO.instance; }
            private set { TableCarDAO.instance = value; }
        }
        //lưu giá trị để sau này có thể dùng lại
        public static int TableWidth = 195;
        public static int TableHeight = 195;

        private TableCarDAO() { }
        //hàm chuyển bàn
        public void SwitchTableCar(int id1, int id2)
        {
            DataProvider.Instance.ExecuteQuery(" USP_SwitchTabelCar @idTableCar1 , @idTableCar2 ", new object[] { id1, id2});
        }
        
        //hàm load danh sách bàn
        public List<TableCar> LoadTableList()
        {
            List<TableCar> tableList = new List<TableCar>();
            DataTable data = DataProvider.Instance.ExecuteQuery("USP_GetTableList");//lấy table lên
            foreach (DataRow item in data.Rows)//trong danh sách dòng lấy ra từng dòng
            {
                TableCar tablecar = new TableCar(item);
                tableList.Add(tablecar);
            }
            return tableList;
        }
    }
}
