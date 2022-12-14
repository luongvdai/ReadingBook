USE [master]
GO
CREATE DATABASE [TEST]
GO
USE [TEST]
GO
/****** Object:  Table [dbo].[Book]    Script Date: 11/10/2021 9:25:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Book](
	[Code] [char](13) NOT NULL,
	[Title] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](45) NOT NULL,
	[Author] [nvarchar](45) NOT NULL,
	[Pub_ID] [int] NULL,
	[Public Date] [date] NULL,
	[Page] [int] NOT NULL,
	[language] [nvarchar](45) NOT NULL,
	[Translator] [nvarchar](45) NULL,
	[NoOfReader] [int] NULL,
	[AvgOfRate] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Publisher]    Script Date: 11/10/2021 9:25:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Publisher](
	[ID] [int] NOT NULL,
	[Name Publisher] [nvarchar](45) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Read]    Script Date: 11/10/2021 9:25:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Read](
	[ID Users] [int] NOT NULL,
	[Code Book] [char](13) NOT NULL,
	[Date From] [datetime] NOT NULL,
	[Date To] [datetime] NOT NULL,
	[Rate] [float] NULL,
 CONSTRAINT [PK__Read__DBBB9AA066A65568] PRIMARY KEY CLUSTERED 
(
	[ID Users] ASC,
	[Code Book] ASC,
	[Date From] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 11/10/2021 9:25:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[ID] [int] NOT NULL,
	[Full Name] [nvarchar](45) NOT NULL,
	[Email] [nvarchar](45) NULL,
	[DOB] [date] NOT NULL,
	[Sex] [char](1) NOT NULL,
	[Phone] [char](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Book]  WITH CHECK ADD FOREIGN KEY([Pub_ID])
REFERENCES [dbo].[Publisher] ([ID])
GO
ALTER TABLE [dbo].[Read]  WITH CHECK ADD  CONSTRAINT [FK__Read__Code Book__52593CB8] FOREIGN KEY([Code Book])
REFERENCES [dbo].[Book] ([Code])
GO
ALTER TABLE [dbo].[Read] CHECK CONSTRAINT [FK__Read__Code Book__52593CB8]
GO
ALTER TABLE [dbo].[Read]  WITH CHECK ADD  CONSTRAINT [FK__Read__ID Users__5165187F] FOREIGN KEY([ID Users])
REFERENCES [dbo].[Users] ([ID])
GO
ALTER TABLE [dbo].[Read] CHECK CONSTRAINT [FK__Read__ID Users__5165187F]
GO
ALTER TABLE [dbo].[Book]  WITH CHECK ADD CHECK  (([Code] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Read]  WITH CHECK ADD  CONSTRAINT [CK__Read__Rate__534D60F1] CHECK  (([Rate]>=(0) AND [Rate]<=(10)))
GO
ALTER TABLE [dbo].[Read] CHECK CONSTRAINT [CK__Read__Rate__534D60F1]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD CHECK  (([Phone] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD CHECK  (([Sex] like '[0-1]'))
GO
/****** Object:  StoredProcedure [dbo].[show]    Script Date: 11/10/2021 9:25:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[show](
@code char(13)
)
as
begin 
	SELECT distinct Users.[Full Name] FROM Users
	Inner join "Read" on "Read".[ID Users] = Users.ID
	WHERE "Read".[Code Book] = @code
end
GO
Create Trigger Insert_Read 
On [Read] 
after Insert, Update
AS
BEGIN
	declare @AvgOfRate float, @NumOfReader int, @code char(13)
	SET @code = (Select i.[Code Book] FROM inserted i)

	SELECT @NumOfReader = count(r.[ID Users]) FROM inserted i , [Read] r WHERE i.[Code Book] = r.[Code Book] Group By i.[Code Book]
	
	SET @AvgOfRate = ((Select avg(r.[Rate])  FROM inserted i, [Read] r WHERE  i.[Code Book] = r.[Code Book] Group By i.[Code Book]))	
	Update Book SET NoOfReader = @NumOfReader, AvgOfRate = @AvgOfRate WHERE Code = @code
END	
GO
Create trigger Del_book
on book
after delete
as
begin
	select * from deleted
end
GO
Create trigger delete_book
on Book
instead of Delete
as
begin
declare @Code_book char(13)
set @Code_book = (select deleted.Code from deleted)
Begin transaction
delete from [Read]
where @Code_book = [Code Book]
if @@ERROR <> 0
BEGIN 
	PRINT 'ERROR'
	rollback
END

delete from Book
where @Code_book = Code
if @@ERROR <> 0
BEGIN 
	PRINT 'ERROR'
	rollback
END
Commit
end

GO
insert into Users(ID, [Full Name], Email, DOB, Sex, Phone)
Values(1, N'Nguyễn Hoàng Minh', 'Minh123@gmail.com', '01/01/2001', 1, '0987654321')
insert into Users(ID, [Full Name], Email, DOB, Sex, Phone)
Values(2, N'Bùi Quang Dương', 'Duong123@gmail.com', '02/02/2001', 1, '0123456789')
insert into Users(ID, [Full Name], Email, DOB, Sex, Phone)
Values(3, N'Lương Văn Đại', Null, '02/02/2001', 1, '0925276125')
insert into Users(ID, [Full Name], Email, DOB, Sex, Phone)
Values(4, N'Phan Trọng Nhân', 'Nhan@gmail.com', '04/04/2001', 1, '0925276125')
GO
insert into Publisher(ID, [Name Publisher])
values(1, N'NXB Trẻ')
insert into Publisher(ID, [Name Publisher])
values(2, N'NXB Phụ Nữ')
insert into Publisher(ID, [Name Publisher])
values(3, N'Nxb Hội Nhà Văn')
insert into Publisher(ID, [Name Publisher])
values(4, N'NXB Lao động')
GO
insert into Book(Code, Title, Category, Author, Pub_ID, [Public Date], [Page], [language], Translator, NoOfReader, AvgOfRate)
values('8934974170617',N'Con Chim Xanh Biếc Bay Về', N'Truyện dài', N'Nguyễn Nhật Ánh', 1, '11/11/2020', 396, 'Vietnamese', Null, 0,0)
insert into Book(Code, Title, Category, Author, Pub_ID, [Public Date], [Page], [language], Translator, NoOfReader, AvgOfRate)
values('8935095622559',N'Thần thoại La Mã', N'Cổ tích & thần thoại', N' G. Chandon', 2, '12/01/2016', 292, 'Vietnamese', N'Nguyễn Bích Như', 0,0)
insert into Book(Code, Title, Category, Author, Pub_ID, [Public Date], [Page], [language], Translator, NoOfReader, AvgOfRate)
values('8935235210912',N'Truyện Ngụ Ngôn La Fontaine', N'Cổ tích & thần thoại', N'La Fontaine', 3, '07/02/2017', 158, 'Vietnamese', N'Nguyễn Trinh Vực', 0,0)
insert into Book(Code, Title, Category, Author, Pub_ID, [Public Date], [Page], [language], Translator, NoOfReader, AvgOfRate)
values('8935251417302',N'Đầu Tư Bất Động Sản', N'Đầu tư & Chứng khoán', N'David Lindahl', 4, '07/13/2021', 392, 'Vietnamese', N'Trần Thăng Long', 0,0)
GO
Insert into [Read]([ID Users], [Code Book], [Date From], [Date To], Rate)
Values(1, '8935095622559', '2021-11-09 17:45:00.000','2021-11-09 18:00:00.000', 5)
Insert into [Read]([ID Users], [Code Book], [Date From], [Date To], Rate)
Values(2, '8935251417302', '2021-11-09 21:00:00.000','2021-11-09 22:00:00.000', 8)
Insert into [Read]([ID Users], [Code Book], [Date From], [Date To], Rate)
Values(3, '8935235210912', '2021-10-09 22:10:00.000','2021-10-09 22:15:00.000', 7)
Insert into [Read]([ID Users], [Code Book], [Date From], [Date To], Rate)
Values(3, '8934974170617', '2021-09-09 20:00:00.000','2021-09-09 21:15:00.000', 4)
Insert into [Read]([ID Users], [Code Book], [Date From], [Date To], Rate)
Values(4, '8935095622559', '2021-10-09 00:00:00.000','2021-11-09 01:15:00.000', 10)
Insert into [Read]([ID Users], [Code Book], [Date From], [Date To], Rate)
Values(2, '8934974170617', '2021-08-09 21:10:00.000','2021-08-09 22:15:00.000', 5)
Insert into [Read]([ID Users], [Code Book], [Date From], [Date To], Rate)
Values(1, '8935095622559', '2021-08-09 00:00:00.000','2021-09-09 22:15:00.000', 8)
Insert into [Read]([ID Users], [Code Book], [Date From], [Date To], Rate)
Values(4, '8935235210912', '2021-10-09 01:00:00.000','2021-11-09 01:15:00.000', 7)