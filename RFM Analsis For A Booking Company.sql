with recency as
(
select contact_id,
'2021-05-27' - max(booking_date::date) as recency
from booking as b
left join payment as p
on b.id=p.booking_id
where payment_status = 'ÇekimBaşarılı'
group by 1
),

frequency as
(
select contact_id,
count(distinct b.id) as frequency
from booking as b
left join payment as p
on b.id=p.booking_id
where payment_status = 'ÇekimBaşarılı'
group by 1
order by 2 desc
),

monetary as
(
select contact_id,
sum(amount) as monetary
from booking as b
left join payment as p
on b.id=p.booking_id
where payment_status = 'ÇekimBaşarılı'
group by 1
	order by 2 desc
),

scores as
(
select r.contact_id,recency, ntile(5) over(order by recency desc) as r_score,	
frequency, 
case when frequency between 1 and 4 then frequency 
else 5 end as f_score,
monetary, ntile(5) over(order by monetary) as m_score
from recency as r
left join frequency as f 
on r.contact_id=f.contact_id
left join monetary as m
on r.contact_id=m.contact_id
)

select contact_id, 
r_score::varchar ||'-'|| f_score::varchar ||'-' || m_score::varchar as overall_scores
from scores 
order by 2 desc



