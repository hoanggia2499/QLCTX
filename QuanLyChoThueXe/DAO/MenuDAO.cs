﻿using QuanLyChoThueXe.DTO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuanLyChoThueXe.DAO
{
  public class MenuDAO
    {
        private static MenuDAO instance;

        public static MenuDAO Instance
        {
            get { if (instance == null) instance = new MenuDAO(); return MenuDAO.instance; }
            private set { MenuDAO.instance = value; }
        }

        private MenuDAO() { }
        //hàm lấy danh sách menu
        public List<Menu> GetListMenuByTableCar(int id)
        {
            List<Menu> listMenu = new List<Menu>();

            string query = "SELECT f.name,f.CMND,f.SDT,f.DiaChi, b.DateCheckIn ,bi.count, f.price, f.price*bi.count AS totalPrice FROM dbo.BillInfo AS bi, dbo.Bill AS b, dbo.KhachHang AS f WHERE bi.idBill = b.id AND bi.idKhachHang = f.id AND b.status=0 AND b.idTableCar = " + id;
            DataTable data = DataProvider.Instance.ExecuteQuery(query);

            foreach (DataRow item in data.Rows)//cho cái datarow trong cái data.row
            {
                Menu menu = new Menu(item);
                listMenu.Add(menu);
            }

            return listMenu;
        }
    }
}
