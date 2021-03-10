require 'pg'

def run_sql(sql, arr = [])
    db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'bitfolio'})
    results = db.exec_params(sql,arr)
    db.close
    return results
end


def check_difference(sell_amount)
    db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'bitfolio'})
    trades = db.exec_params('select * from trades where user_id = $1', [current_user()['id']])

    amount_total = get_total(trades)

    difference = amount_total - sell_amount

    return difference

end