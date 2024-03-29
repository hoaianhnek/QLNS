﻿
create database BOOKSTORE_MANAGEMENT;
use BOOKSTORE_MANAGEMENT;

create table SACH
(
MASACH INT primary key not null,
TENSACH VARCHAR(255),
THELOAI VARCHAR(255),
TACGIA VARCHAR(255),
SOLUONGTON INT
);

CREATE TABLE TAIKHOAN
(
TENDN VARCHAR(100) PRIMARY KEY,
MATKHAU VARCHAR(100),
);

CREATE TABLE NHANVIEN
(
MANV INT PRIMARY KEY NOT NULL,
TENNV VARCHAR(255),
DIACHI VARCHAR(255),
GIOITINH VARCHAR(5),
CMND CHAR(9),
TENDN VARCHAR(100),
CONSTRAINT FK_NV_TK FOREIGN KEY (TENDN) REFERENCES TAIKHOAN(TENDN)
);

create table KHACHHANG
(
MAKH INT primary key not null,
TENKH VARCHAR(255),
NQL INT,
DIACHI VARCHAR(255),
SDT int,
EMAIL VARCHAR(255),
CONGNO MONEY,
CONSTRAINT FK_KH_NV FOREIGN KEY (NQL) REFERENCES NHANVIEN(MANV)
);

create table HOADON
(
SOHD INT PRIMARY KEY NOT NULL IDENTITY(1,1),
NGAYLAP SMALLDATETIME,
MANV INT,
CONSTRAINT FK_HD_NV FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV)
);

create table CTHD
(
SOHD INT NOT NULL IDENTITY(1,1),
MAKH INT NOT NULL,
MASACH INT NOT NULL,
SOLUONGBAN INT,
DONGIABAN MONEY,
THANHTIEN MONEY,
TIENTRA MONEY,
PRIMARY KEY(SOHD,MAKH,MASACH),
CONSTRAINT FK_CTHD_HD FOREIGN KEY (SOHD) REFERENCES HOADON(SOHD),
CONSTRAINT FK_CTHD_KH FOREIGN KEY (MAKH) REFERENCES KHACHHANG(MAKH),
constraint FK_CTHD_S FOREIGN KEY (MASACH) REFERENCES SACH(MASACH)
);

create table PHIEUNHAP
(
SOPN INT PRIMARY KEY NOT NULL IDENTITY(1,1),
NGAYNHAP SMALLDATETIME,
MANV INT,
CONSTRAINT FK_PN_NV FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV)
);

create table CTPN
(SOPN int IDENTITY(1,1),
MASACH INT,
SOLUONGNHAP INT,
DONGIANHAP MONEY,
THANHTIEN MONEY,
PRIMARY KEY(SOPN,MASACH),
constraint fk_CTPN_PN FOREIGN KEY (SOPN) REFERENCES PHIEUNHAP(SOPN),
CONSTRAINT FK_CTPN_S FOREIGN KEY (MASACH) REFERENCES SACH(MASACH)
);

create table PHIEUTHUTIEN
(
SOPTT INT PRIMARY KEY NOT NULL IDENTITY(1,1),
MAKH INT,
MANV INT,
NGAYTHUTIEN SMALLDATETIME,
SOTIENTHU MONEY,
CONSTRAINT FK_PTT_KH FOREIGN KEY (MAKH) REFERENCES KHACHHANG(MAKH),
CONSTRAINT FK_PTT_NV FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV)
);

CREATE TABLE QUIDINH
(
SOLUONGNHAPTOITHIEU INT,
LUONGTONTOIDATRUOCNHAP INT,
TIENNOTOIDA money,
LUONGTONTOITHIEUSAUBAN int,
QUIDINH4 int            -- 0-sử dụng   1-không sử dụng
);
ALTER TABLE QUIDINH ADD CHECK (QUIDINH4>=0 and QUIDINH4 <=1);


--Thêm và sửa chi tiết phiếu nhập
CREATE TRIGGER trgINS_UPDCTPN ON CTPN
FOR INSERT,UPDATE
AS
BEGIN
	IF EXISTS(SELECT * FROM SACH S JOIN INSERTED I ON S.MASACH=I.MASACH
						WHERE S.SOLUONGTON>=(select LUONGTONTOIDATRUOCNHAP from QUIDINH))
			BEGIN 
					PRINT 'KHONG NHAP SACH'
					ROLLBACK TRAN
			END
			IF EXISTS(SELECT * FROM INSERTED WHERE SOLUONGNHAP<(select SOLUONGNHAPTOITHIEU from QUIDINH))
				BEGIN 
				PRINT 'KHONG NHAP SACH'
				ROLLBACK TRAN
				END
		UPDATE SACH
		SET SOLUONGTON=SOLUONGTON+I.SOLUONGNHAP
		FROM SACH S JOIN INSERTED I ON S.MASACH=I.MASACH
		COMMIT TRAN;
END;

	
-- Thêm và sửa hóa đơn
CREATE TRIGGER trgINS_UPDCTHD ON CTHD
FOR INSERT,UPDATE
AS
BEGIN
	IF EXISTS(SELECT * FROM INSERTED I JOIN KHACHHANG KH ON I.MAKH=KH.MAKH
				WHERE KH.CONGNO>(SELECT TIENNOTOIDA FROM QUIDINH))
		BEGIN 
			PRINT' KHONG BAN'
			ROLLBACK TRAN
		END
		DECLARE @LUONGTONSAUBAN INT;
		SELECT @LUONGTONSAUBAN=S.SOLUONGTON-I.SOLUONGBAN
		FROM SACH S JOIN INSERTED I ON S.MASACH=I.MASACH
		IF EXISTS(SELECT * FROM SACH S JOIN INSERTED I ON I.MASACH=S.MASACH
					WHERE @LUONGTONSAUBAN<(SELECT LUONGTONTOITHIEUSAUBAN FROM QUIDINH))
				BEGIN 
					PRINT ' KHONG BAN'
					ROLLBACK TRAN
				END
	UPDATE SACH
	SET SOLUONGTON=SOLUONGTON-I.SOLUONGBAN
	FROM SACH S JOIN INSERTED I ON S.MASACH=I.MASACH
	UPDATE KHACHHANG
	SET CONGNO=CONGNO+I.THANHTIEN-I.TIENTRA
	FROM KHACHHANG KH JOIN INSERTED I ON KH.MAKH=I.MAKH
END;

--Tính đơn giá bán
CREATE PROC spDONGIABAN
	@DONGIANHAP MONEY,
	@MASACH INT,
	@DONGIABAN MONEY OUT
AS
BEGIN
	DECLARE @SOLUONGTON INT
	SELECT @SOLUONGTON=SOLUONGTON,@DONGIANHAP=DONGIANHAP FROM SACH S JOIN CTPN ON S.MASACH=CTPN.MASACH
	IF @SOLUONGTON<1
		BEGIN
			PRINT 'HET SACH'
			ROLLBACK TRAN
		END
		BEGIN
			SET @DONGIABAN=1.05*@DONGIANHAP;
			COMMIT TRAN;
		END
END;

--Thêm phiếu thu tiền
CREATE TRIGGER trgINSERTPHIEUTHUTIEN
ON PHIEUTHUTIEN
FOR INSERT
AS
BEGIN
	IF EXISTS(SELECT * FROM INSERTED I JOIN KHACHHANG KH ON I.MAKH=KH.MAKH
							WHERE SOTIENTHU>CONGNO)
				BEGIN
					PRINT 'KHONG LAP DUOC PHIEU THU TIEN'
					ROLLBACK TRAN
				END
END;

--Thêm và xóa qui định
CREATE TRIGGER TRGINSERTDELETEQUIDINH
ON QUIDINH
FOR INSERT,DELETE
AS
BEGIN
	PRINT ' KHONG THE THEM HOAC XOA THAM SO QUI DINH'
END;

	
	--Lập phiếu nhập sách
CREATE PROC spLAPPHIEUNHAPSACH
	@MASACH INT,
	@SOLUONGNHAP INT,
	@MANV INT,
	@DONGIANHAP MONEY
AS
BEGIN
	DECLARE @THANHTIEN MONEY, @NGAYNHAP SMALLDATETIME
	SET @THANHTIEN=@SOLUONGNHAP*@DONGIANHAP;
	SET @NGAYNHAP=GETDATE();
	INSERT INTO PHIEUNHAP(NGAYNHAP,MANV) VALUES (@NGAYNHAP,@MANV)
	INSERT INTO CTPN(MASACH,SOLUONGNHAP,DONGIANHAP,THANHTIEN) VALUES(@MASACH,@SOLUONGNHAP,@DONGIANHAP,@THANHTIEN)
END;

	--Lập hóa đơn bán sách
CREATE PROC spLAPHOADONBANSACH
	@MAKH INT,
	@MASACH INT,
	@MANV INT,
	@SOLUONGBAN INT,
	@TIENTRA MONEY
AS
BEGIN
	DECLARE @THANHTIEN MONEY,@DONGIANHAP MONEY,@DONGIABAN MONEY,@NGAYLAP SMALLDATETIME
	EXEC spDONGIABAN @DONGIANHAP,@MASACH,@DONGIABAN;
	SET @THANHTIEN=@SOLUONGBAN*@DONGIABAN;
	SET @NGAYLAP=GETDATE();
	INSERT INTO HOADON(NGAYLAP,MANV) VALUES (@NGAYLAP,@MANV);
	INSERT INTO CTHD(MAKH,MASACH,SOLUONGBAN,DONGIABAN,THANHTIEN,TIENTRA) VALUES (@MAKH,@MASACH,@SOLUONGBAN,@DONGIABAN,@THANHTIEN,@TIENTRA);
END;

--Lập báo cáo tồn
CREATE PROC spLAPBAOCAOTON
	@MAS INT,
	@THANG INT,
	@NAM INT,
	@TONCUOI INT OUT
AS 
BEGIN
		SET @TONCUOI = 0;
		IF EXISTS(SELECT * FROM PHIEUNHAP PN JOIN CTPN ON PN.SOPN=CTPN.SOPN
					WHERE YEAR(NGAYNHAP)<=@NAM AND MASACH=@MAS)
			BEGIN
				DECLARE @SL INT
				DECLARE csCTPN CURSOR FOR SELECT SOLUONGNHAP FROM CTPN JOIN PHIEUNHAP PN ON CTPN.SOPN=PN.SOPN
											WHERE MONTH(NGAYNHAP)<=@THANG AND YEAR(NGAYNHAP)=@NAM AND MASACH=@MAS
											UNION
											SELECT SOLUONGNHAP FROM CTPN JOIN PHIEUNHAP PN ON CTPN.SOPN=PN.SOPN
											WHERE YEAR(NGAYNHAP)<@NAM
			END

			OPEN csCTPN
			FETCH NEXT FROM csCTPN INTO @SL
			WHILE(@@FETCH_STATUS=0)
				BEGIN 
					SET @TONCUOI=@TONCUOI+@SL
					COMMIT TRAN;
				END
			CLOSE csCTPN;
			DEALLOCATE csCTPN;
		    DECLARE csCTHD CURSOR FOR SELECT SOLUONGBAN FROM HOADON HD  JOIN CTHD ON HD.SOHD=CTHD.SOHD
									 WHERE MONTH(NGAYLAP) <= @THANG AND YEAR(NGAYLAP) = @NAM AND MASACH = @MAS
									 UNION
									 SELECT SOLUONGBAN FROM HOADON HD JOIN CTHD ON HD.SOHD=CTHD.SOHD
									 WHERE YEAR(NGAYLAP) < @NAM AND MASACH = @MAS
			 OPEN csCTHD
			 FETCH NEXT FROM csCTHD INTO @SL
			 WHILE @@FETCH_STATUS = 0
                BEGIN
                   SET @TONCUOI = @TONCUOI - @SL
				   COMMIT TRAN;
                END
			CLOSE csCTHD;
			DEALLOCATE csCTHD;
END;
--Lập báo cáo công nợ
CREATE PROC spLAPBAOCAOCONGNO
	@MAKH INT,
	@THANG INT,
	@NAM INT,
	@NOCUOI MONEY OUT
AS
BEGIN
	SET @NOCUOI=0;
	IF EXISTS(SELECT * FROM PHIEUTHUTIEN WHERE YEAR(NGAYTHUTIEN)<=@NAM AND @MAKH=MAKH)
		BEGIN
			DECLARE @SOTIENTRA MONEY
			DECLARE csPHIEUTHUTIEN CURSOR FOR	SELECT SOTIENTHU FROM PHIEUTHUTIEN 
												WHERE MONTH(NGAYTHUTIEN)<=@THANG AND YEAR(NGAYTHUTIEN)=@NAM AND MAKH=@MAKH
												UNION
												SELECT SOTIENTHU FROM PHIEUTHUTIEN 
												WHERE YEAR(NGAYTHUTIEN)<@NAM AND MAKH=@MAKH
			OPEN csPHIEUTHUTIEN
			FETCH NEXT FROM csPHIEUTHUTIEN INTO @SOTIENTRA
			WHILE @@FETCH_STATUS=0
				BEGIN
					SET @NOCUOI=@NOCUOI-@SOTIENTRA;
					COMMIT TRAN;
				END
			CLOSE csPHIEUTHUTIEN;
			DEALLOCATE csPHIEUTHUTIEN;
		END
END