using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuanLyChoThueXe.DAO
{
    public class DataProvider
    {
        //cấu trúc sigleton
        private static DataProvider instance;//nếu bất cứ thứ cái gì lấy qua thông qua instance là duy nhất

        public static DataProvider Instance
        {
            get { if (instance == null) instance = new DataProvider(); return DataProvider.instance; }
            private set { DataProvider.instance = value; }
        }

        private DataProvider() { } //Hàm dựng đảm bảo bên ngoài k tác động dô được chỉ lấy ra thôi

        private string connectionSTR = "Data Source=(LocalDB)\\MSSQLLocalDB;Initial Catalog=QuanLyChoThueXe;User ID=sa;Password=123456; Integrated Security=True"; // string conection là cái chuỗi để mà xác định nó sẽ kết nối với thằng nào
        // Hàm hiện thị dữ liệu lên DataTable
        public DataTable ExecuteQuery(string query, object[] parameter = null)
        {
            DataTable data = new DataTable();
            //dù có vấn đề gì khi kết thúc khối lệnh bên trong cái dữ liệu được khai báo sẽ được giải phóng
            using (SqlConnection connection = new SqlConnection(connectionSTR))// là kết nối từ sqlclient này xuống sever
            {
                connection.Open();//mở connection
                //command (mặc định command type = text nên chúng ta khỏi phải làm gì nhiều)
                SqlCommand command = new SqlCommand(query, connection);//command này là câu truy vấn nó thực thi
                //add được n parameter
                if (parameter != null)
                {
                    string[] listPara = query.Split(' ');//split theo khoang trắng
                    int i = 0;
                    foreach (string item in listPara)
                    {
                        if (item.Contains('@'))//có nghĩa là nó chứa parameter
                        {
                            command.Parameters.AddWithValue(item, parameter[i]);
                            i++;
                        }
                    }
                }
                //định nghĩa đối tượng thuộc lớp SqlDataAdapter
                SqlDataAdapter adapter = new SqlDataAdapter(command);// đây là trung gian thực hiện câu truy vấn để lấy dữ liệu ra 

                adapter.Fill(data); // đổ dữ liệu lấy ra vào cái data cần phải mở connection ra mới dùng được

                connection.Close();// đóng connection
            }

            return data;
        }
        //phương thức thực thi query
        public int ExecuteNonQuery(string query, object[] parameter = null)//ktra số dòng thành công
        {
            int data = 0;

            using (SqlConnection connection = new SqlConnection(connectionSTR))
            {
                connection.Open();

                SqlCommand command = new SqlCommand(query, connection);

                if (parameter != null)
                {
                    string[] listPara = query.Split(' ');
                    int i = 0;
                    foreach (string item in listPara)
                    {
                        if (item.Contains('@'))
                        {
                            command.Parameters.AddWithValue(item, parameter[i]);
                            i++;
                        }
                    }
                }

                data = command.ExecuteNonQuery();

                connection.Close();
            }

            return data;
        }
        //phương thức thực thi query,//Đếm số lượng
        public object ExecuteScalar(string query, object[] parameter = null)// cần số lượng trả ra tức là 1 cái ô 1 cái dòng trong dataset
        {
            object data = 0;

            using (SqlConnection connection = new SqlConnection(connectionSTR))
            {
                connection.Open();

                SqlCommand command = new SqlCommand(query, connection);

                if (parameter != null)
                {
                    string[] listPara = query.Split(' ');
                    int i = 0;
                    foreach (string item in listPara)
                    {
                        if (item.Contains('@'))
                        {
                            command.Parameters.AddWithValue(item, parameter[i]);
                            i++;
                        }
                    }
                }

                data = command.ExecuteScalar();

                connection.Close();
            }

            return data;
        }
    }
}
