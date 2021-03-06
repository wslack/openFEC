drop materialized view if exists ofec_sched_e_aggregate_candidate_mv_tmp;
create materialized view ofec_sched_e_aggregate_candidate_mv_tmp as
with records as (
    select
        cmte_id,
        s_o_cand_id as cand_id,
        s_o_ind as support_oppose_indicator,
        rpt_yr,
        rpt_tp,
        memo_cd,
        exp_amt
    from sched_e
    union all
    select
        filer_cmte_id as cmte_id,
        s_o_cand_id as cand_id,
        s_o_in as support_oppose_indicator,
        rpt_yr,
        rpt_tp,
        null as memo_cd,
        exp_amt
    from form_57
    join form_5
        on (form_5.sub_id = form_57.link_id)
)
select
    row_number() over () as idx,
    cmte_id,
    cand_id,
    support_oppose_indicator,
    rpt_yr + rpt_yr % 2 as cycle,
    sum(exp_amt) as total,
    count(exp_amt) as count
from records
where
    exp_amt is not null and
    rpt_tp not in ('24', '48') and
    (memo_cd != 'X' or memo_cd is null)
group by
    cmte_id,
    cand_id,
    support_oppose_indicator,
    cycle
;

create unique index on ofec_sched_e_aggregate_candidate_mv_tmp (idx);

create index on ofec_sched_e_aggregate_candidate_mv_tmp (cmte_id);
create index on ofec_sched_e_aggregate_candidate_mv_tmp (cand_id);
create index on ofec_sched_e_aggregate_candidate_mv_tmp (support_oppose_indicator);
create index on ofec_sched_e_aggregate_candidate_mv_tmp (cycle);
create index on ofec_sched_e_aggregate_candidate_mv_tmp (total);
create index on ofec_sched_e_aggregate_candidate_mv_tmp (count);
