using QuanLyChoThueXe.DAO;
using QuanLyChoThueXe.DTO;
using QuanLyChoThueXe.GUI;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Menu = QuanLyChoThueXe.DTO.Menu;

namespace QuanLyChoThueXe
{
    public partial class fGiaoDien : Form
    {
        private Account loginAccount;

        public Account LoginAccount
        {
            get { return loginAccount; }
            set { loginAccount = value; ChangeAccount(LoginAccount.Type); }
        }

        public fGiaoDien(Account acc)
        {
            InitializeComponent();
            this.LoginAccount = acc;//truyền tài khoản đăng nhập
            LoadTableCar();
            LoadKhach();
            LoadComboboxTableCar(cbSwitchTableCar);
        }

       
        #region Method
        //Hàm kiểm tra xem tài khoản thuộc loại nào, nếu tài khoản là loại 0 (admin) thì mới có quyền truy cập vào chức năng quản lý
        void ChangeAccount(int type)
        {
            adminToolStripMenuItem.Enabled = type == 0;
            thôngTinTàiKhoảnToolStripMenuItem.Text += " (" + LoginAccount.DisplayName + ")";
        }

        void LoadTableCar()//Load table car lên
        {
            flpTableCar.Controls.Clear();
            List<TableCar> tableList = TableCarDAO.Instance.LoadTableList();//lấy được danh sách table

            foreach (TableCar item in tableList)//với mỗi tablecar nằm trong cái table list sẽ tạo ra 1 cái buton
            {
                Button btn = new Button() { Width = TableCarDAO.TableWidth, Height = TableCarDAO.TableHeight };
                btn.Text = item.Name + Environment.NewLine + item.Status;//tên xe + trạng thái của xe
                btn.Click += btn_Click;//event click
                btn.Tag = item;//gắn tablecar id (lưu luôn tablecar vào)
                switch (item.Status)
                {
                    case "Trống":
                        btn.BackColor = Color.AntiqueWhite;
                        break;
                    case "Xe Hỏng":
                        btn.BackColor = Color.Red;
                        break;
                    default:
                        btn.BackColor = Color.SaddleBrown;
                        break;
                }

                flpTableCar.Controls.Add(btn);
            }
        }

        //hàm show bill
        void ShowBill(int id)
        {
            lsvBill.Items.Clear();
            List<Menu> listBillInfo = MenuDAO.Instance.GetListMenuByTableCar(id);//lấy ra ListBillInfo
            float totalPrice = 0;
            foreach (Menu item in listBillInfo)//cho mỗi cái menu nằm trong listbillinfo
            {
                ListViewItem lsvItem = new ListViewItem(item.KhachName.ToString());//tạo ra listviewitem
                lsvItem.SubItems.Add(item.Cmnd.ToString());
                lsvItem.SubItems.Add(item.Sdt.ToString());
                lsvItem.SubItems.Add(item.Diachi.ToString());
                lsvItem.SubItems.Add(item.DateCheckin.ToString());
                lsvItem.SubItems.Add(item.Count.ToString());
                lsvItem.SubItems.Add(item.Price.ToString());
                lsvItem.SubItems.Add(item.TotalPrice.ToString());
                totalPrice += item.TotalPrice;

                lsvBill.Items.Add(lsvItem);
            }
            CultureInfo culture = new CultureInfo("vi-VN");
            //Thread.CurrentThread.CurrentCulture = culture;

            txbToltalPrrice.Text = totalPrice.ToString("c", culture);
        }
        //hàm load danh sach khach
        void LoadKhach()
        {
            List<Khach> listKhach = KhachDAO.Instance.GetListKhach();
            cbKhach.DataSource = listKhach;
            cbKhach.DisplayMember = "Name";
        }

        //
        void LoadKhachByID(int id)
        {
            List<Khach> listKhach = KhachDAO.Instance.GetListKhach();
            cbKhach.DataSource = listKhach;
            cbKhach.DisplayMember = "Name";
        }

        //event Đặt xe
        private void btnAddCar_Click(object sender, EventArgs e)
        {
            TableCar tablecar = lsvBill.Tag as TableCar;

            if (tablecar == null)//
            {
                MessageBox.Show("Xin hãy chọn xe!");
                return;
            }

            int idBill = BillDAO.Instance.GetUncheckBillIDByCarID(tablecar.ID);
            int KhachID = (cbKhach.SelectedItem as Khach).ID;
            int count = (int)nmDateCount.Value;

            if (idBill == -1)//nếu idbill =-1 tạo ra bill mới r add vào table là idbill idkhách và số lượng
            {
                BillDAO.Instance.InsertBill(tablecar.ID);
                BillInfoDAO.Instance.InsertBillInfo(BillDAO.Instance.GetMaxIDBill(), KhachID, count);
            }
            else//ngược lại!=-1 thì nó có cái id bill vừa query ra r thêm khách dô
            {
                BillInfoDAO.Instance.InsertBillInfo(idBill, KhachID, count);
            }
            ShowBill(tablecar.ID);

            LoadTableCar();
        }
        //even thanh toán
        private void btnCheckOut_Click(object sender, EventArgs e) // khi minh chon thanh toan se checkout
        {
            TableCar tablecar = lsvBill.Tag as TableCar;//lay table hien tai
            int idBill = BillDAO.Instance.GetUncheckBillIDByCarID(tablecar.ID); //lay idbill ra

            int discount = (int)nmDisCount.Value;//lấy giá trị discount

            double toltalPrice = Convert.ToDouble(txbToltalPrrice.Text.Split(',')[0].Replace(".", ""));//xử lý chuỗi và cắt chuỗi lấy ra phần đầu tiên
            double tienthutruoc = toltalPrice * (0.5);
            double finalTotalPrice = toltalPrice - (toltalPrice / 100) * discount;
            double sotiencanthu = finalTotalPrice - tienthutruoc;

            if (idBill != -1)
            {
                if (MessageBox.Show(string.Format("Bạn có chắc thanh toán hóa đơn cho {0} !\n ***Tổng tiền là {1} (Giảm giá {2}%) \n  = {3}đ( đã thu trước 50%) \n số tiền cần phải thu là {4}  ", tablecar.Name, toltalPrice, discount, finalTotalPrice,sotiencanthu), "Thông báo", MessageBoxButtons.OKCancel) == System.Windows.Forms.DialogResult.OK)
                {
                    BillDAO.Instance.CheckOut(idBill, discount, (float)finalTotalPrice);
                    ShowBill(tablecar.ID);

                    LoadTableCar();
                }

            }
        }
        #endregion
        private void btn_Click(object sender, EventArgs e)//khi nhấn vào sẽ show hóa đơn
        {
            int TableID = ((sender as Button).Tag as TableCar).ID;//lấy id của table
            lsvBill.Tag = (sender as Button).Tag;
            ShowBill(TableID);
        }
        //
        private void thôngTinCáNhânToolStripMenuItem_Click(object sender, EventArgs e)
        {
            fAccountProfile f = new fAccountProfile(loginAccount);
            f.UpdateAccount += f_UpdateAccount;
            f.ShowDialog();
        }
        //
        private void f_UpdateAccount(object sender, AccountEvent e)
        {
            thôngTinTàiKhoảnToolStripMenuItem.Text = "Thông tin tài khoản (" + e.Acc.DisplayName + ")";
        }
        //
        private void đăngXuấtToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }
        private void adminToolStripMenuItem_Click(object sender, EventArgs e)
        {
            fAdmin f = new fAdmin();
            f.loginAccount = LoginAccount;
           
            f.ShowDialog();
        }
        
        void f_UpdateKhach(object sender, EventArgs e)
        {
            LoadKhachByID((cbKhach.SelectedItem as Khach).ID);
            if (lsvBill.Tag != null)
                ShowBill((lsvBill.Tag as TableCar).ID);
        }
        //
        void f_DeleteKhach(object sender, EventArgs e)
        {
            LoadKhachByID((cbKhach.SelectedItem as Khach).ID);
            if (lsvBill.Tag != null)
                ShowBill((lsvBill.Tag as TableCar).ID);
            LoadTableCar();
        }
        //
        void f_InsertKhach(object sender, EventArgs e)
        {
            LoadKhachByID((cbKhach.SelectedItem as Khach).ID);
            if (lsvBill.Tag != null)
                ShowBill((lsvBill.Tag as TableCar).ID);
        }
        
        private void cbKhach_SelectedIndexChanged(object sender, EventArgs e)
        {
            int id = 1;
            ComboBox cb = sender as ComboBox;

            if (cb.SelectedItem == null)
                return;
            Khach selected = cb.SelectedItem as Khach;
            id = selected.ID;
            LoadKhachByID(id);//load danh sách
        }

        private void quanLyToolStripMenuItem_Click(object sender, EventArgs e)
        {
            fKhachHang f = new fKhachHang();
            f.InsertKhach += f_InsertKhach;
            f.DeleteKhach += f_DeleteKhach;
            f.UpdateKhach += f_UpdateKhach;
            f.ShowDialog();
        }
        //Hàm đổi xe
        private void btnSwitchTableCar_Click(object sender, EventArgs e)
        {
            int id1 = (lsvBill.Tag as TableCar).ID;

            int id2 = (cbSwitchTableCar.SelectedItem as TableCar).ID;
            string sta = (lsvBill.Tag as TableCar).Status;

            if (MessageBox.Show(string.Format("Bạn có thật sự muốn chuyển {0}\n {1} qua {2}  ", (lsvBill.Tag as TableCar).Name, (lsvBill.Tag as TableCar).Status,(cbSwitchTableCar.SelectedItem as TableCar).Name),  "Thông báo", MessageBoxButtons.OKCancel) == System.Windows.Forms.DialogResult.OK)
            {
                TableCarDAO.Instance.SwitchTableCar(id1, id2);

                LoadTableCar();
                
            }
            
        }

        //Load tablecar vao combobox
        void LoadComboboxTableCar(ComboBox cb)
        {
            cb.DataSource = TableCarDAO.Instance.LoadTableList();
            cb.DisplayMember = "Name";
        }
        //Hàm Hủy Đặt Xe
        private void btnHuy_Click(object sender, EventArgs e)
        {
            TableCar tablecar = lsvBill.Tag as TableCar;//lay table hien tai
            int idBill = BillDAO.Instance.GetUncheckBillIDByCarID(tablecar.ID); //lay idbill ra

            int discount = (int)nmDisCount.Value;//lấy giá trị discount

            double toltalPrice = Convert.ToDouble(txbToltalPrrice.Text.Split(',')[0].Replace(".", ""));//xử lý chuỗi và cắt chuỗi lấy ra phần đầu tiên
            double finalTotalPrice = toltalPrice * (0.1) ;

            if (idBill != -1)
            {
                if (MessageBox.Show(string.Format("Bạn có chắc chắn hủy hóa đơn đặt xe cho {0} !\n ***Tổng tiền 10% từ {1} = {2}đ ", tablecar.Name, toltalPrice, finalTotalPrice), "Thông báo", MessageBoxButtons.OKCancel) == System.Windows.Forms.DialogResult.OK)
                {
                    BillDAO.Instance.CheckOut(idBill, discount, (float)finalTotalPrice);
                    ShowBill(tablecar.ID);

                    LoadTableCar();
                }

            }
        }

        private void flpTableCar_Paint(object sender, PaintEventArgs e)
        {

        }

        private void lsvBill_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void panel2_Paint(object sender, PaintEventArgs e)
        {

        }
    }
}
