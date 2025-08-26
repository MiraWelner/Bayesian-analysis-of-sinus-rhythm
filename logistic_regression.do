egen user_rank = group(shhs_id)

mlogit label_one heart_rate sdnn if user_rank <= 10

drop user_rank
