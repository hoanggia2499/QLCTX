create database QuanLyChoThueXe
Go
use QuanLyChoThueXe
Go

Create table Account(
	UserName nvarchar (100) PRIMARY KEY, 
	DisplayName NVARCHAR(100) NOT NULL DEFAULT N'member',
	PassWord nvarchar (100)NOT NULL DEFAULT 0,
	Type int NOT NULL DEFAULT 0 -- 0: admin && 1: staff
)
go
insert into Account values('admin','admin','1',0)
insert into Account values('user','user','0',1)
go
select * from Account

----
CREATE PROC USP_GetAccountByUserName
@userName nvarchar(100)
AS 
BEGIN
	SELECT * FROM dbo.Account WHERE UserName = @userName
END
GO

EXEC dbo.USP_GetAccountByUserName @userName = N'k9' -- nvarchar(100)

GO
----
CREATE PROC USP_Login --tai khoản đăng nhập
@userName nvarchar(100), @passWord nvarchar(100)
AS
BEGIN
	SELECT * FROM dbo.Account WHERE UserName = @userName AND PassWord = @passWord
END
GO
--Tạo bảng nhân viên
Create table Nhanvien(
	id int IDENTITY PRIMARY KEY,
	UserName nvarchar (100) , 
	CMND int,
	SDT int,
	NgaySinh date,
	GioiTinh nchar(3),
	QueQuan nvarchar(100)
)
go

drop table Nhanvien
insert into Nhanvien values(N'Lê Đức Hiển',2152324,0924245252,'1999-1-1',N'Nam','An Giang')
select * from Nhanvien

--Trạng thái xe đã thuê hay trống
CREATE TABLE TableCar 
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Xe chưa có tên',
	status NVARCHAR(100) NOT NULL DEFAULT N'Trống'	-- Trống || Có người || Xe đang sửa chửa
)
GO

drop table TableCar

--Danh sách khách hàng
CREATE TABLE KhachHang
(
	id INT NOT NULL IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Chưa đặt tên' ,
	CMND int,
	SDT int,
	GioiTinh nchar(3),
	DiaChi nvarchar(100),
	price FLOAT NOT NULL DEFAULT 0 
	
)
GO
-- thêm Khách Hàng

INSERT dbo.KhachHang
        ( name, CMND,SDT,GioiTinh,DiaChi,price )
VALUES  ( N'Lê Đức Hiển', -- name - nvarchar(100)
          7796784,--CMND
		  0337689046,--SDT
		  N'Nam',--Giới Tính
		  N'Quận 8-TPHCM',
		  1000000--price
		  )
Go
select * from KhachHang
UPDATE dbo.KhachHang SET name = N'{Thành Tiến}', cmnd=23434 , sdt =038973,gioitinh=N'Nam',diachi=N'Thủ Đức' WHERE id =18 
Delete KhachHang where id= 1
select name  from KhachHang where id=1
select *from KhachHang
Delete KhachHang where id=2
drop table KhachHang
--Bill đã thanh toán hay chưa thanh toán
CREATE TABLE Bill
(
	id INT IDENTITY PRIMARY KEY,
	DateCheckIn DATE NOT NULL DEFAULT GETDATE(),
	DateCheckOut DATE,
	idTableCar INT NOT NULL,
	status INT NOT NULL DEFAULT 0, -- 1: đã thanh toán && 0: chưa thanh toán
	discount INT,
	totalPrice FLOAT

	FOREIGN KEY (idTableCar) REFERENCES dbo.TableCar(id)
)
GO

drop table Bill
select * from Bill
-- thêm bill
INSERT	dbo.Bill
        ( DateCheckIn ,
          DateCheckOut ,
          idTableCar ,
          status
        )
VALUES  ( GETDATE() , -- DateCheckIn - date
          NULL , -- DateCheckOut - date
          3 , -- idTable - int
          0  -- status - int
        )
--Tạo BillInfo
CREATE TABLE BillInfo
(
	id INT IDENTITY PRIMARY KEY,
	idBill INT NOT NULL,
	idKhachHang INT NOT NULL,
	count INT NOT NULL DEFAULT 0
	
	FOREIGN KEY (idBill) REFERENCES dbo.Bill(id),
	FOREIGN KEY (idKhachHang) REFERENCES dbo.KhachHang(id)
)
GO

drop table BillInfo
-- thêm bill info
INSERT	dbo.BillInfo
        ( idBill, idKhachHang, count )
VALUES  ( 1, -- idBill - int
          1, -- idkhachhang - int
          1  -- count - int
          )
select * from BillInfo


-- thêm bàn
DECLARE @i INT = 1,@j int =9000,@a INT = 4,@b int =9000

WHILE @i <= 3 and @j <=10000 and @a <=6  and @b<=10000
BEGIN
	INSERT dbo.TableCar(name)VALUES  ( N'Xe ' + CAST(@i AS nvarchar(100)) + N' ' + N'Ford Everest Trắng '+N' 59-A' + CAST(@j AS nvarchar(100)) +N' 7 chỗ')
	INSERT dbo.TableCar(name)VALUES  ( N'Xe ' + CAST(@a AS nvarchar(100)) + N' ' + N'Ford Everest Đen '+N' 59-A' + CAST(@b AS nvarchar(100)) +N' 7 chỗ')
	SET @i = @i + 1 
	SET	@j=@j+1
	SET @a = @a + 1 
	SET	@b=@b+3
	
END
GO
UPDATE dbo.TableCar (name) SET

--Lấy danh sách xe
CREATE PROC USP_GetTableList
AS SELECT * FROM dbo.TableCar
GO
UPDATE dbo.TableCar SET STATUS = N'Có người' WHERE id = 4
EXEC dbo.USP_GetTableList
GO
--



drop proc USP_InsertBill
-----tạo proc insertbill
CREATE PROC USP_InsertBill
@idTableCar INT
AS
BEGIN
	INSERT dbo.Bill 
	        ( DateCheckIn ,
	          DateCheckOut ,
	          idTableCar ,
	          status,
	          discount
			  
	        )
	VALUES  ( GETDATE() , -- DateCheckIn - date
	          NULL , -- DateCheckOut - date
	          @idTableCar , -- idTableCar - int
	          0,  -- status - int
	          0--discount
	        )
END
GO
drop proc USP_InsertBillInfo
-------
CREATE PROC USP_InsertBillInfo
@idBill INT, @idKhachHang INT, @count INT
AS
BEGIN

	DECLARE @isExitsBillInfo INT
	DECLARE @dateCount INT = 1
	
	SELECT @isExitsBillInfo = id, @dateCount = b.count 
	FROM dbo.BillInfo AS b 
	WHERE idBill = @idBill AND idKhachHang= @idKhachHang

	IF (@isExitsBillInfo > 0)
	BEGIN
		DECLARE @newCount INT = @dateCount + @count
		IF (@newCount > 0)
			UPDATE dbo.BillInfo	SET count = @dateCount + @count WHERE idKhachHang = @idKhachHang
		ELSE
			DELETE dbo.BillInfo WHERE idBill = @idBill AND idKhachHang = @idKhachHang
	END
	ELSE
	BEGIN
		INSERT	dbo.BillInfo
        ( idBill, idKhachHang, count )
		VALUES  ( @idBill, -- idBill - int
          @idKhachHang, -- idFood - int
          @count  -- count - int
          )
	END
END
GO

-----
CREATE TRIGGER UTG_UpdateBillInfo
ON dbo.BillInfo FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @idBill INT
	
	SELECT @idBill = idBill FROM Inserted
	
	DECLARE @idTableCar INT
	
	SELECT @idTableCar = idTableCar FROM dbo.Bill WHERE id = @idBill AND status = 0	
	
	DECLARE @count INT
	SELECT @count = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idBill
	
	IF (@count > 0)
	BEGIN
	
		PRINT @idTableCar
		PRINT @idBill
		PRINT @count
		
		UPDATE dbo.TableCar SET status = N'Có người Thuê' WHERE id = @idTableCar		
		
	END		
	ELSE
	BEGIN
	PRINT @idTableCar
		PRINT @idBill
		PRINT @count
	UPDATE dbo.TableCar SET status = N'Trống' WHERE id = @idTableCar	
	end
	
END
GO
-----Update Bill
CREATE TRIGGER UTG_UpdateBill
ON dbo.Bill FOR UPDATE
AS
BEGIN
	DECLARE @idBill INT
	
	SELECT @idBill = id FROM Inserted	
	
	DECLARE @idTablecar INT
	
	SELECT @idTableCar = idTableCar FROM dbo.Bill WHERE id = @idBill
	
	DECLARE @count int = 0
	
	SELECT @count = COUNT(*) FROM dbo.Bill WHERE idTablecar = @idTableCar AND status = 0
	
	IF (@count = 0)
		UPDATE dbo.TableCar SET status = N'Trống' WHERE id = @idTableCar
END
GO
---

----Trigger xóa billinfo
CREATE TRIGGER UTG_DeleteBillInfo
ON dbo.BillInfo FOR DELETE
AS 
BEGIN
	DECLARE @idBillInfo INT
	DECLARE @idBill INT
	SELECT @idBillInfo = id, @idBill = Deleted.idBill FROM Deleted
	
	DECLARE @idTableCar INT
	SELECT @idTableCar = idTableCar FROM dbo.Bill WHERE id = @idBill
	
	DECLARE @count INT = 0
	
	SELECT @count = COUNT(*) FROM dbo.BillInfo AS bi, dbo.Bill AS b WHERE b.id = bi.idBill AND b.id = @idBill AND b.status = 0
	
	IF (@count = 0)
		UPDATE dbo.TableCar SET status = N'Trống' WHERE id = @idTableCar
END
GO



select * from BillInfo

DROP PROCEDURE USP_SwitchTabelCar
----Proc Chuyển xe
CREATE PROC USP_SwitchTabelCar
@idTableCar1 INT, @idTableCar2 int
AS BEGIN

	DECLARE @idFirstBill int
	DECLARE @idSeconrdBill INT
	
	DECLARE @isFirstTablEmty INT = 1
	DECLARE @isSecondTablEmty INT = 1
	
	
	SELECT @idSeconrdBill = id FROM dbo.Bill WHERE idTableCar = @idTableCar2 AND status = 0
	SELECT @idFirstBill = id FROM dbo.Bill WHERE idTableCar = @idTableCar1 AND status = 0
	
	PRINT @idFirstBill
	PRINT @idSeconrdBill
	PRINT '-----------'
	
	IF (@idFirstBill IS NULL)
	BEGIN
		PRINT '0000001'
		INSERT dbo.Bill
		        ( DateCheckIn ,
		          DateCheckOut ,
		          idTableCar ,
		          status
		        )
		VALUES  ( GETDATE() , -- DateCheckIn - date
		          NULL , -- DateCheckOut - date
		          @idTableCar1 , -- idTable - int
		          0  -- status - int
		        )
		        
		SELECT @idFirstBill = MAX(id) FROM dbo.Bill WHERE idTableCar = @idTableCar1 AND status = 0
		
	END
	
	SELECT @isFirstTablEmty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idFirstBill
	
	PRINT @idFirstBill
	PRINT @idSeconrdBill
	PRINT '-----------'
	
	IF (@idSeconrdBill IS NULL)
	BEGIN
		PRINT '0000002'
		INSERT dbo.Bill
		        ( DateCheckIn ,
		          DateCheckOut ,
		          idTableCar ,
		          status
		        )
		VALUES  ( GETDATE() , -- DateCheckIn - date
		          NULL , -- DateCheckOut - date
		          @idTableCar2 , -- idTable - int
		          0  -- status - int
		        )
		SELECT @idSeconrdBill = MAX(id) FROM dbo.Bill WHERE idTableCar = @idTableCar2 AND status = 0
		
	END
	
	SELECT @isSecondTablEmty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idSeconrdBill
	
	PRINT @idFirstBill
	PRINT @idSeconrdBill
	PRINT '-----------'

	SELECT id INTO IDBillInfoTable FROM dbo.BillInfo WHERE idBill = @idSeconrdBill
	
	UPDATE dbo.BillInfo SET idBill = @idSeconrdBill WHERE idBill = @idFirstBill
	
	UPDATE dbo.BillInfo SET idBill = @idFirstBill WHERE id IN (SELECT * FROM IDBillInfoTable)
	
	DROP TABLE IDBillInfoTable
	
	IF (@isFirstTablEmty = 0)
		UPDATE dbo.TableCar SET status = N'Trống' WHERE id = @idTableCar2
		
	IF (@isSecondTablEmty= 0)
		UPDATE dbo.TableCar SET status = N'Trống' WHERE id = @idTableCar1
END
GO

select * from Nhanvien

-----
CREATE PROC USP_UpdateAccount
@userName NVARCHAR(100), @displayName NVARCHAR(100), @password NVARCHAR(100), @newPassword NVARCHAR(100)
AS
BEGIN
	DECLARE @isRightPass INT = 0
	
	SELECT @isRightPass = COUNT(*) FROM dbo.Account WHERE USERName = @userName AND PassWord = @password
	
	IF (@isRightPass = 1)
	BEGIN
		IF (@newPassword = NULL OR @newPassword = '')
		BEGIN
			UPDATE dbo.Account SET DisplayName = @displayName WHERE UserName = @userName
		END		
		ELSE
			UPDATE dbo.Account SET DisplayName = @displayName, PassWord = @newPassword WHERE UserName = @userName
	end
END
GO

CREATE FUNCTION [dbo].[fuConvertToUnsign1]
 ( @strInput NVARCHAR(4000) ) RETURNS NVARCHAR(4000) 
 AS BEGIN

 IF @strInput IS NULL RETURN @strInput 

 IF @strInput = '' RETURN @strInput DECLARE @RT NVARCHAR(4000) 

 DECLARE @SIGN_CHARS NCHAR(136) DECLARE @UNSIGN_CHARS NCHAR (136) 

 SET @SIGN_CHARS = N'ăâđêôơưàảãạáằẳẵặắầẩẫậấèẻẽẹéềểễệế ìỉĩịíòỏõọóồổỗộốờởỡợớùủũụúừửữựứỳỷỹỵý ĂÂĐÊÔƠƯÀẢÃẠÁẰẲẴẶẮẦẨẪẬẤÈẺẼẸÉỀỂỄỆẾÌỈĨỊÍ ÒỎÕỌÓỒỔỖỘỐỜỞỠỢỚÙỦŨỤÚỪỬỮỰỨỲỶỸỴÝ' +NCHAR(272)+ NCHAR(208) 
 SET @UNSIGN_CHARS = N'aadeoouaaaaaaaaaaaaaaaeeeeeeeeee iiiiiooooooooooooooouuuuuuuuuuyyyyy AADEOOUAAAAAAAAAAAAAAAEEEEEEEEEEIIIII OOOOOOOOOOOOOOOUUUUUUUUUUYYYYYDD' 

 DECLARE @COUNTER int 
 DECLARE @COUNTER1 int SET @COUNTER = 1 WHILE (@COUNTER <=LEN(@strInput)) 

 BEGIN SET @COUNTER1 = 1 WHILE (@COUNTER1 <=LEN(@SIGN_CHARS)+1) 
 BEGIN 
 IF UNICODE(SUBSTRING(@SIGN_CHARS, @COUNTER1,1)) = UNICODE(SUBSTRING(@strInput,@COUNTER ,1) ) 
 BEGIN IF @COUNTER=1 SET @strInput = SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@strInput, @COUNTER+1,LEN(@strInput)-1) 
 ELSE SET @strInput = SUBSTRING(@strInput, 1, @COUNTER-1) +SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@strInput, @COUNTER+1,LEN(@strInput)- @COUNTER) 
 BREAK END SET @COUNTER1 = @COUNTER1 +1 END SET @COUNTER = @COUNTER +1 END SET @strInput = replace(@strInput,' ','-') RETURN @strInput 
 END

 -----Lây Danh Sách bill theo Ngày
CREATE PROC USP_GetListBillByDate
@checkIn date, @checkOut date
AS 
BEGIN
	SELECT b.id AS [ID Bill] ,t.name AS [Tên Xe]  ,bi.idKhachHang AS [ID Khách Hàng], DateCheckIn AS [Ngày Thuê], DateCheckOut AS [Ngày Trả], discount AS [Giảm giá],b.totalPrice AS [Tổng tiền]
	FROM dbo.Bill AS b,dbo.TableCar AS t,dbo.BillInfo AS bi
	WHERE DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
	AND t.id = b.idTableCar  AND bi.idKhachHang = bi.idKhachHang AND bi.idBill = b.id
END
GO
drop proc USP_GetListBillByDate

 ---lay bill theo ngay va trang
CREATE PROC USP_GetListBillByDateAndPage
@checkIn date, @checkOut date, @page int
AS 
BEGIN
	DECLARE @pageRows INT = 10
	DECLARE @selectRows INT = @pageRows
	DECLARE @exceptRows INT = (@page - 1) * @pageRows
	
	;WITH BillShow AS( SELECT b.id , t.name AS [Tên Xe],bi.idKhachHang AS [ID Khách Hàng], DateCheckIn AS [Ngày Thuê], DateCheckOut AS [Ngày Trả], discount AS [Giảm giá],b.totalPrice AS [Tổng tiền]
	FROM dbo.Bill AS b,dbo.TableCar AS t,dbo.BillInfo AS bi
	WHERE DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
	AND t.id = b.idTableCar AND bi.idKhachHang = bi.idKhachHang AND b.id=bi.idbill)
	
	SELECT TOP (@selectRows) * FROM BillShow WHERE id NOT IN (SELECT TOP (@exceptRows) id FROM BillShow)
END
GO
drop proc USP_GetListBillByDateAndPage
-----
CREATE PROC USP_GetNumBillByDate
@checkIn date, @checkOut date 
AS 
BEGIN
	SELECT COUNT(*)
	FROM dbo.Bill AS b,dbo.TableCar AS t,dbo.BillInfo AS bi
	WHERE DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
	AND t.id = b.idTableCar
END
GO
drop proc USP_GetNumBillByDate




