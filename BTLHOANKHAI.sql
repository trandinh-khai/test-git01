CREATE DATABASE QLCHUOITHUCPHAMSACH1;
USE QLCHUOITHUCPHAMSACH;

CREATE TABLE LoaiThucPham (
    MaLoai INT PRIMARY KEY,
    TenLoai NVARCHAR(50)
);
SELECT * FROM LoaiThucPham;


CREATE TABLE ThucPham (
    MaTP INT PRIMARY KEY,
    TenTP NVARCHAR(100),
    MaLoai INT FOREIGN KEY REFERENCES LoaiThucPham(MaLoai),
    Gia DECIMAL(10,2),
    HanSuDung DATE
);
SELECT * FROM ThucPham;


CREATE TABLE NhanVien (
    MaNV INT PRIMARY KEY,
    TenNV NVARCHAR(50),
    ChucVu NVARCHAR(50),
    Luong DECIMAL(10,2)
);
SELECT * FROM NhanVien;


CREATE TABLE HoaDonXuat (
    MaHDX INT PRIMARY KEY,
    NgayXuat DATE,
    MaNV INT FOREIGN KEY REFERENCES NhanVien(MaNV)
);
SELECT * FROM HoaDonXuat;


CREATE TABLE ChiTietHoaDonXuat (
    MaHDX INT FOREIGN KEY REFERENCES HoaDonXuat(MaHDX),
    MaTP INT FOREIGN KEY REFERENCES ThucPham(MaTP),
    SoLuong INT,
    PRIMARY KEY (MaHDX, MaTP)
);
SELECT * FROM ChiTietHoaDonXuat;

INSERT INTO LoaiThucPham VALUES 
(1, N'Rau củ'), (2, N'Trái cây'), (3, N'Thịt cá'), (4, N'Sữa và chế phẩm từ sữa'), (5, N'Gạo và ngũ cốc'),
(6, N'Gia vị'), (7, N'Đồ uống'), (8, N'Thực phẩm đông lạnh'), (9, N'Đồ hộp'), (10, N'Thực phẩm khô');

INSERT INTO ThucPham VALUES 
(1, N'Cà chua', 1, 15000, '2024-05-10'), (2, N'Cam sành', 2, 40000, '2024-04-15'),
(3, N'Thịt bò', 3, 250000, '2024-03-30'), (4, N'Sữa tươi', 4, 30000, '2024-06-01'),
(5, N'Gạo ST25', 5, 35000, '2025-01-01'), (6, N'Muối tinh', 6, 10000, '2026-12-31'),
(7, N'Nước ép táo', 7, 45000, '2024-09-20'), (8, N'Cá hồi đông lạnh', 8, 500000, '2024-08-15'),
(9, N'Pate hộp', 9, 80000, '2025-05-10'), (10, N'Mì gói', 10, 5000, '2025-02-20');

INSERT INTO NhanVien VALUES 
(1, N'Nguyễn Văn A', N'Quản lý', 15000000), (2, N'Trần Thị B', N'Nhân viên kho', 7000000),
(3, N'Đỗ C', N'Nhân viên bán hàng', 8000000), (4, N'Lê Văn D', N'Nhân viên thu ngân', 7500000),
(5, N'Hoàng Thị E', N'Nhân viên kiểm hàng', 7200000), (6, N'Phan Văn F', N'Nhân viên bảo vệ', 6000000),
(7, N'Ngô Thị G', N'Nhân viên giao hàng', 6500000), (8, N'Trịnh Văn H', N'Nhân viên kế toán', 9000000),
(9, N'Lâm Thị I', N'Nhân viên kho', 7200000), (10, N'Vũ Văn J', N'Nhân viên bán hàng', 7800000);

INSERT INTO HoaDonXuat VALUES 
(1, '2024-03-10', 1), (2, '2024-03-11', 2), (3, '2024-03-12', 3), (4, '2024-03-13', 4),
(5, '2024-03-14', 5), (6, '2024-03-15', 6), (7, '2024-03-16', 7), (8, '2024-03-17', 8),
(9, '2024-03-18', 9), (10, '2024-03-19', 10);

INSERT INTO ChiTietHoaDonXuat VALUES 
(1, 1, 5), (1, 2, 3), (2, 3, 2), (2, 4, 6), (3, 5, 10), (3, 6, 7), (4, 7, 8), (4, 8, 4), (5, 9, 5), (5, 10, 12);

--VIEW VÀ CHỈ MỤC
IF EXISTS (SELECT * FROM sys.views WHERE name = 'ViewThucPham')
DROP VIEW ViewThucPham;
GO

CREATE VIEW ViewThucPham AS
SELECT tp.MaTP, tp.TenTP, l.TenLoai, tp.Gia, tp.HanSuDung 
FROM ThucPham tp JOIN LoaiThucPham l ON tp.MaLoai = l.MaLoai;
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_NhanVien_Luong')
DROP INDEX IX_NhanVien_Luong ON NhanVien;
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ThucPham_TenTP')
DROP INDEX IX_ThucPham_TenTP ON ThucPham;
GO

CREATE NONCLUSTERED INDEX IX_NhanVien_Luong ON NhanVien(Luong);
GO

CREATE NONCLUSTERED INDEX IX_ThucPham_TenTP ON ThucPham(TenTP);
GO


CREATE PROCEDURE ThemNhanVien @MaNV INT, @TenNV NVARCHAR(50), @ChucVu NVARCHAR(50), @Luong DECIMAL(10,2)
AS
BEGIN
    INSERT INTO NhanVien VALUES (@MaNV, @TenNV, @ChucVu, @Luong);
END;

EXEC ThemNhanVien 11, N'Bùi Văn K', N'Nhân viên vận chuyển', 7200000;

CREATE FUNCTION fn_TinhTongLuong()
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TongLuong DECIMAL(10,2);
    SELECT @TongLuong = SUM(Luong) FROM NhanVien;
    RETURN @TongLuong;
END;

SELECT dbo.fn_TinhTongLuong();


CREATE VIEW ViewNhanVien AS
SELECT MaNV, TenNV, ChucVu, Luong FROM NhanVien;
GO



CREATE VIEW ViewHoaDonChiTiet AS
SELECT hd.MaHDX, hd.NgayXuat, nv.TenNV, tp.TenTP, ctx.SoLuong, tp.Gia, (ctx.SoLuong * tp.Gia) AS ThanhTien
FROM HoaDonXuat hd
JOIN NhanVien nv ON hd.MaNV = nv.MaNV
JOIN ChiTietHoaDonXuat ctx ON hd.MaHDX = ctx.MaHDX
JOIN ThucPham tp ON ctx.MaTP = tp.MaTP;
GO


CREATE VIEW ViewThucPhamGiaCao AS
SELECT * FROM ThucPham WHERE Gia > 50000;
GO

CREATE VIEW VW_Top3ThucPhamBanItNhat AS
SELECT TOP 3 TP.MaTP, TP.TenTP, SUM(CT.SoLuong) AS TongSoLuongBan
FROM ChiTietHoaDonXuat CT
JOIN ThucPham TP ON CT.MaTP = TP.MaTP
GROUP BY TP.MaTP, TP.TenTP
ORDER BY TongSoLuongBan ASC;


CREATE VIEW ViewTongDoanhThuNgay AS
SELECT hd.NgayXuat, SUM(ctx.SoLuong * tp.Gia) AS TongDoanhThu
FROM HoaDonXuat hd
JOIN ChiTietHoaDonXuat ctx ON hd.MaHDX = ctx.MaHDX
JOIN ThucPham tp ON ctx.MaTP = tp.MaTP
GROUP BY hd.NgayXuat;
GO


CREATE VIEW ViewNhanVienLuongCao AS
SELECT * FROM NhanVien WHERE Luong > 8000000;
GO


CREATE VIEW ViewSoLuongThucPhamTheoLoai AS
SELECT lt.MaLoai, lt.TenLoai, COUNT(tp.MaTP) AS SoLuongSanPham
FROM LoaiThucPham lt
LEFT JOIN ThucPham tp ON lt.MaLoai = tp.MaLoai
GROUP BY lt.MaLoai, lt.TenLoai;
GO


CREATE VIEW VW_ThucPhamHetHan AS
SELECT MaTP, TenTP, HanSuDung
FROM ThucPham
WHERE HanSuDung < GETDATE();

CREATE VIEW VW_DoanhThuNhanVien AS
SELECT NV.MaNV, NV.TenNV, SUM(CT.SoLuong * TP.Gia) AS TongDoanhThu
FROM HoaDonXuat HDX
JOIN NhanVien NV ON HDX.MaNV = NV.MaNV
JOIN ChiTietHoaDonXuat CT ON HDX.MaHDX = CT.MaHDX
JOIN ThucPham TP ON CT.MaTP = TP.MaTP
GROUP BY NV.MaNV, NV.TenNV;

CREATE VIEW VW_Top3ThucPhamBanChay AS
SELECT TOP 3 TP.MaTP, TP.TenTP, SUM(CT.SoLuong) AS TongSoLuongBan
FROM ChiTietHoaDonXuat CT
JOIN ThucPham TP ON CT.MaTP = TP.MaTP
GROUP BY TP.MaTP, TP.TenTP
ORDER BY TongSoLuongBan DESC;





IF OBJECT_ID('trg_KiemTraGiaThucPham', 'TR') IS NOT NULL
    DROP TRIGGER trg_KiemTraGiaThucPham;
GO
CREATE TRIGGER trg_KiemTraGiaThucPham
ON ThucPham
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Gia < 0)
    BEGIN
        RAISERROR(N'Giá thực phẩm không được nhỏ hơn 0!', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO
SELECT Gia FROM ThucPham;



IF OBJECT_ID('trg_CapNhatLuong', 'TR') IS NOT NULL
    DROP TRIGGER trg_CapNhatLuong;
GO
CREATE TRIGGER trg_CapNhatLuong
ON NhanVien
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Luong)
    BEGIN
        PRINT N'Đã cập nhật lương nhân viên!';
    END
END;
GO
SELECT Luong FROM NhanVien;



IF OBJECT_ID('trg_LogHoaDonXuat', 'TR') IS NOT NULL
    DROP TRIGGER trg_LogHoaDonXuat;
GO
CREATE TRIGGER trg_LogHoaDonXuat
ON HoaDonXuat
AFTER INSERT
AS
BEGIN
    PRINT N'Hóa đơn xuất mới đã được thêm!';
END;
GO
SELECT * FROM HoaDonXuat;


IF OBJECT_ID('trg_KhongXoaQuanLy', 'TR') IS NOT NULL
    DROP TRIGGER trg_KhongXoaQuanLy;
GO
CREATE TRIGGER trg_KhongXoaQuanLy
ON NhanVien
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM deleted WHERE ChucVu = N'Quản lý')
    BEGIN
        RAISERROR(N'Không thể xóa nhân viên quản lý!', 16, 1);
        ROLLBACK TRAN;
    END
    ELSE
    BEGIN
        DELETE FROM NhanVien WHERE MaNV IN (SELECT MaNV FROM deleted);
    END
END;
GO
SELECT * FROM NhanVien;


IF OBJECT_ID('trg_CapNhatGiaThucPham', 'TR') IS NOT NULL
    DROP TRIGGER trg_CapNhatGiaThucPham;
GO
CREATE TRIGGER trg_CapNhatGiaThucPham
ON ThucPham
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Gia <= 0)
    BEGIN
        UPDATE ThucPham SET Gia = 10000 WHERE Gia <= 0;
        PRINT N'Giá thực phẩm không hợp lệ, đã cập nhật về 10,000!';
    END
END;
GO
SELECT Gia FROM ThucPham;


IF OBJECT_ID('trg_GhiLogXoaHoaDon', 'TR') IS NOT NULL
    DROP TRIGGER trg_GhiLogXoaHoaDon;
GO
CREATE TRIGGER trg_GhiLogXoaHoaDon
ON HoaDonXuat
AFTER DELETE
AS
BEGIN
    INSERT INTO LogHoaDonXuat (MaHDX, NgayXuat, MaNV)
    SELECT MaHDX, NgayXuat, MaNV FROM deleted;
    PRINT N'Đã ghi log hóa đơn bị xóa!';
END;
GO
SELECT * FROM HoaDonXuat;


IF OBJECT_ID('trg_KiemTraSoLuong', 'TR') IS NOT NULL
    DROP TRIGGER trg_KiemTraSoLuong;
GO
CREATE TRIGGER trg_KiemTraSoLuong
ON ChiTietHoaDonXuat
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE SoLuong <= 0)
    BEGIN
        RAISERROR(N'Số lượng sản phẩm trong hóa đơn phải lớn hơn 0!', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO
SELECT SoLuong FROM ChiTietHoaDonXuat;


IF OBJECT_ID('TRG_CheckHanSuDung_Insert', 'TR') IS NOT NULL
    DROP TRIGGER TRG_CheckHanSuDung_Insert;
GO
CREATE TRIGGER TRG_CheckHanSuDung_Insert
ON ThucPham
FOR INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM INSERTED WHERE HanSuDung < GETDATE())
    BEGIN
        RAISERROR (N'Thực phẩm đã hết hạn, không thể thêm!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
SELECT HanSuDung FROM ThucPham;



-- TẠO NGƯỜI DÙNG NHÂN VIÊN
CREATE LOGIN NhanVien WITH PASSWORD = 'NhanVien@123';
CREATE USER NhanVien FOR LOGIN NhanVien;
EXEC sp_helprotect NULL, 'NhanVien';



