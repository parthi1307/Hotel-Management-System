create database project;
use project;

-- CREATING GUEST TABLE TO STORE GUEST DETAILS
create table guests(guest_id int primary key auto_increment,
guest_name varchar(50) not null,
email varchar(70) unique not null,
phone_number varchar(20) unique not null);

-- CREATING A PROCEDURE TO STORE GUEST DETAILS
delimiter //
create procedure guest_details(in guestname varchar(50),in email varchar(70),in p_number varchar(20))
begin
     insert into guests(guest_name,email,phone_number) values (guestname,email,p_number);
end //
delimiter ;

call guest_details('Ravi','ravi@gmail.com','7739620374');
select * from guests;
select count(*) as total_guests from guests;

-- CREATNG ROOM TYPES TABLE TO STORE TYPES OF ROOMS AVAILABLE
create table room_types(type_id int primary key auto_increment,
type_name varchar(30) unique not null,
price_per_night int not null);

insert into room_types(type_name,price_per_night) values ('single',1000),
('double',2000),
('suite',3000);
insert into room_types(type_name,price_per_night)values('twin',3500);

-- CREATING A VIEW TO SHOW RENTAL DETAILS
create view rental_details as select * from room_types;
select * from rental_details;

-- CREATING ROOMS TABLE TO STORE THE NUMBER OF ROOMS
create table rooms(room_id int auto_increment primary key,
room_number varchar(20),
type_id int,
status varchar(20) default 'Available',
foreign key (type_id) references room_types(type_id));

insert into rooms(room_number,type_id,status) values ('101G',1,'available'),
('102G',2,'available'),
('103G',3,'available'),
('201F',1,'available');
insert into rooms(room_number,type_id) values ('202F',2),('203F',4);
select * from rooms;

-- CREATING BOOKINGS TABLE TO STORE BOOKING DETAILS
create table bookings(booking_id int auto_increment primary key,
guest_id int not null,
room_id int not null,
check_in_date date,
check_out_date date,
total_price decimal(10,2) not null,
foreign key(guest_id)references guests(guest_id),
foreign key(room_id) references rooms(room_id));

select * from bookings;

-- CREATING PAYMENTS TABLE TO STORE PAYMENT DETAILS
create table payments(payment_id int auto_increment primary key,
booking_id int not null,
amount decimal(10,2) not null,
payment_date datetime,
payment_method enum('cash','credit card','debit card','upi','net banking'),
foreign key(booking_id) references bookings(booking_id));
desc payments;

-- CREATING A INDEX FOR STATUS OF ROOMS
create index idx_room_status on rooms(status);

-- CREATING A VIEW TO SEE ROOM AVAILABILITY
create view room_availability as select * from rooms where status='available';
select * from room_availability;

-- CREATING A VIEW TO SEE ROOM OCCUPANCY
create view view_occupancy as select * from rooms where status = 'occupied';
select * from view_occupancy;

-- CREATING A PROCEDURE TO BOOK ROOMS WITH INPUTS AS GUEST ID,ROOM ID,CHECHIN DATE,CHECKOUT DATE
delimiter //
create procedure book_room(in p_guest_id int,in p_room_id int,p_checkin date,p_checkout date)
begin
     declare price_p_night decimal(10,2);
     declare total_amount decimal(10,2);
     declare nights int;
     start transaction;
     set nights= datediff(p_checkout,p_checkin);
     if nights<=0 then
     set nights=1;
     end if;
     select rt.price_per_night into price_p_night from room_types rt
     inner join rooms r
     on r.type_id=rt.type_id
     where r.room_id=p_room_id;
     set total_amount = nights * price_p_night;

     insert into bookings(guest_id,room_id,check_in_date,check_out_date,total_price) 
     values (p_guest_id,p_room_id,p_checkin,p_checkout,total_amount);
     update rooms set status= 'occupied' where room_id=p_room_id;
     commit;
end //
delimiter ;

-- CREATING A TRIGGER TO CHECK DATE VALIDITY(CHECKOUT DATE >= CHECKIN DATE)
delimiter //
create trigger checkdate
before insert on bookings
for each row 
begin
     if new.check_out_date < new.check_in_date then
     signal sqlstate '45000'
     set message_text='Error; checkout date must not be earlier than checkin date';
     end if;
end //
delimiter ;
 
-- CREATING A PROCEDURE FOR CHECKOUT WITH INPUTS AS BOOKING ID AND PAYMENT METHOD
delimiter //
create procedure checkout(in p_booking_id int,in p_payment_method varchar(20))
begin
	 declare total_amount decimal(10,2);
     declare roomid int;
     
     start transaction;
     select total_price,room_id into total_amount,roomid from bookings where booking_id=p_booking_id;
     
     insert into payments(booking_id,amount,payment_date,payment_method)
     values (p_booking_id,total_amount,now(),p_payment_method);
     
     update rooms set status = 'available' where room_id=roomid;
     
     commit;
end //
delimiter ;

-- CREATING A HISTORY TABLE TO STORE THE BOOKING HISTORY
create table history(
booking_id int,
guest_id int,
room_id int,
check_in_date date,
check_out_date date,
total_price decimal(10,2));

select * from history;

-- CREATING A TRIGGER FOR STORING BOOKING DETAILS IN HISTORY TABLE
delimiter //
create trigger after_insert_bookings
after insert on bookings
for each row
begin
     insert into history(booking_id,guest_id,room_id,check_in_date,check_out_date,total_price)
     values (new.booking_id,new.guest_id,new.room_id,new.check_in_date,new.check_out_date,new.total_price);
end //
delimiter ;

-- BOOKING EXAMPLE 1
call book_room(1,3,'2026-06-25','2026-06-27');
select * from bookings;
-- CHECKOUT EXAMPLE 1
call checkout(3,'net banking');

-- BOOKING EXAMPLE 2
call book_room(2,4,'2026-06-25','2026-06-27');
-- CHECKOUT EXAMPLE 2
call checkout(4,'upi');

select * from payments;

-- TOTAL PAYMENTS DONE BASED ON PAYMENT METHOD
select payment_method,sum(amount) as total_revenue
from payments group by payment_method;