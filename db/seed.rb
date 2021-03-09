require_relative 'db/lib'

  
# titles1 = %w| 2020-09-22 2021-01-20 smelly nelly dark |
# titles2 = %w| cake pudding muffin ribs candy chicken |

# user_id = run_sql("SELECT * FROM users;").first[:id]


# 10.times do

#     run_sql("insert into dishes (title, image_url, user_id) values ($1, $2, $3)",
#     [   
#         "#{titles1.sample} #{titles2.sample}",
#         'https://via.placeholder.com/150',
#         user_id
#     ])
# end



INSERT INTO trades(trade_date, trade_type, amount, price, total) VALUES ('2020-09-22', 'BUY', 1.0, 10481, 10481);

INSERT INTO trades(trade_date, trade_type, amount, price, total) VALUES ('2021-01-20', 'SELL', 0.5, 35622.3, 17811.15);

INSERT INTO trades(trade_date, trade_type, amount, price, total) VALUES ('2021-02-15', 'BUY', 1.6, 47983.95, 76774.32);

INSERT INTO trades(trade_date, trade_type, amount, price, total) VALUES ('2021-02-01', 'BUY', 1.1, 47983.95, 49000);

INSERT INTO trades(trade_date, trade_type, amount, price, total) VALUES ('2021-02-02', 'SELL', 0.2, 47000, 8000);


