<?include_once _FEMALE_TEMPLATES_PATH .'common/header_meta.tpl'?>
<body id="pay_daily" class="pay jam <?=$_SERVER['X_GLAS_APPID']?> dailies">
<!--<?include_once _FEMALE_TEMPLATES_PATH .'common/header.tpl'?>-->
<link rel="stylesheet" type="text/css" href="/common/css/goal.css">
<link rel="stylesheet" type="text/css" href="/secret/css/goal.css">

<div class="tab three">
	<ul>
		<li id="tab_1" class=""><a href="/point/">報酬確認</a></li>
		<li id="tab_2" class="active"><a href="/point/daily/">日別報酬</a></li>
		<li id="tab_3" class=""><a href="/point/ranking/">ランキング</a></li>
	</ul>
</div>

<section id="main">

	<script>
		$(function(){
			$('.thermometer').thermometer();
		});
	</script>

	<?if ( $invalidFlg === true ) { ?>
	<?=join("<br>\n",$msg)?>
	<?} else {?>

	<div class="tab_month">

	<?if (strtotime($date . " -1 month") >= $limitDate) { ?>
	<li><a class="" href="?date=<?=date("Ym",strtotime($date . " -1 month"))?>">先月をみる</a></li>
	<?} else {?>
	<li class="active"><span class="">先月をみる</span></li>
	<?}?>
	<?if (strtotime($date . " +1 month") < time()) { ?>
	<li><a class="" href="?date=<?=date("Ym",strtotime($date . " +1 month"))?>">次月をみる</a></li>
	<?} else {?>
	<li class="active"><span class="">次月をみる</span></li>
	<?}?>

	</div>
	<!-- <a id="debug_popup" href="javascript:void(0);" style="display: block; width: 100%;padding: 5% 0; text-align: center;">※【デバック用】ポップアップ表示</a> -->

	<p class="daily_tit-date"><?=date("Y年m月",strtotime($startDate))?></p>

	<div class="goal">
		<div class="goal-monthly-wrap">
			<div class="goal-monthly">
				<p class="goal-monthly__title">今月の目標</p>
				<p class="goal-monthly__number">
					<?php if ($hasTargetSetting) : ?>
					<span class="main_color"><?= number_format($targetPoints) ?></span><span class="unit is_monthliy">pts</span>
					<?php else : ?>
					<span class="main_color">目標未設定</span>
					<?php endif; ?>
				</p>
				<a class="goal-monthly__edit" href="javascript:void(0);"><img class="goal-monthly__image" src="/common/img/ic_goal_edit_kyuun.png" alt="" style="width: 20px;;margin: auto;"></a>
			</div>
		</div>
		<dl class="goal-now">
			<dt class="goal-now__title">現在の獲得ポイント</dt>
			<dd class="goal-now__number"><span class="main_color"><?= number_format($currentTotal) ?></span><span class="unit is_now">pts</span></dd>
		</dl>
		<dl class="goal-rate">
			<dt class="goal-rate__title">目標達成率</dt>
			<dd class="goal-rate__number">
				<?php if ($hasTargetSetting) : ?>
				<span class="main_color"><?= round($currentTotal / $targetPoints * 100) ?></span><span class="unit is_rate">%</span>
				<?php else : ?>
					<span class="main_color">--</span>
				<?php endif; ?>
			</dd>
		</dl>
	</div>
	<?php if ($hasTargetSetting) : ?>
	<div class="chart">
		<p class="chart__hero"><span class="main_color">達成状況グラフ</span></p>
		<canvas id="line-chart" class="chrat__canvas"></canvas>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/1.0.2/Chart.min.js"></script>
		<script>
			var lineChartData = {
				//イベント開催期間（5日刻みで出力のこりは空欄)
				labels : <?= json_encode($dayLabels) ?>,
			datasets : [
				{
					label: "目標",
					fill : false,
					fillColor            :"#cce4ff",
					pointColor           :"rgba(255,0,0,0)",
					strokeColor          :"rgba(255,0,0,0)",
					pointStrokeColor     : "rgba(255,0,0,0)",
					pointHighlightFill   : "rgba(255,0,0,0)",
					pointHighlightStroke : "rgba(255,0,0,0)",

					//日付分の目標ポイントを複数回入力
					data : <?= json_encode($targetPointArray); ?>
			},{
				label: "pts",
						fill : false,
						pointHighlightFill   : "#fff",
						pointHighlightStroke : "rgba(221,156,180,0.6)",
						//日付ごとの獲得ポイント
						data : <?= json_encode($realPointArr); ?>
			}]
			};

			window.onload = function(){
				var ctx = document.getElementById("line-chart").getContext("2d");
                var gradientStroke = ctx.createLinearGradient(500, 0, 100, 0);
                gradientStroke.addColorStop(0, "#25265F");
                gradientStroke.addColorStop(1, "#0C92A8");

                lineChartData["datasets"][1]["fillColor"] = gradientStroke;
                lineChartData["datasets"][1]["pointColor"] = gradientStroke;
                lineChartData["datasets"][1]["strokeColor"] = gradientStroke;
                lineChartData["datasets"][1]["pointStrokeColor"] = gradientStroke;

				window.myLine = new Chart(ctx).Line(lineChartData, {
					scaleOverride : true,
					bezierCurve: false,
					scaleOverride: true,
					scaleFontSize: 10,
					showTooltips: false,

					//以下設定で、縦軸のレンジは、最小値0から1000区切りで10000(0+1000*10)までになる。
					//目標獲得ポイントが少ないのはグラフ上限値を低くしたい。

					//縦軸の区切りの数
					scaleSteps : 10,
					//縦軸の目盛り区切りの間隔
					scaleStepWidth : <?= $step; ?>,
				//縦軸の目盛りの最小値
				scaleStartValue : 0,
			});
			}
		</script>
		<ul class="note-list">
			<li class="note-list__item is_get-point">獲得ポイント</li>
			<li class="note-list__item is_necessary-point">目標ライン</li>
		</ul>
	</div>
	<?php endif; ?>
	<div class="daily" style="background: #fff;">
		<p class="daily__hero">日別獲得ポイント</p>
		<table class="daily_table" style="width: 91%;">
			<tr>
				<th class="date_col"></th>
				<th class="merter_col"></th>
			</tr>
			<?foreach ($range as $day) {?>
			<?$day = sprintf("%02d", $day)?>
			<tr class="<?=date("D",strtotime($yearMonth.$day))?>" style="background: #fff;">
			<td class="date">
			<a href="/point/detail/?date=<?=date("Y-m-d",strtotime($yearMonth.$day))?>" style="text-decoration: underline;"><?=date($format,strtotime($date)).$day?></a>
			</td>
			<td class="meter">
			<? if ( isset($data[date("Y-m-",strtotime($date)).$day]) ) { ?>
			<div class="thermometer" data-percent="<?= $max ? floor($data[date("Y-m-",strtotime($date)).$day]/$max*100) : 0; ?>" data-speed="slow"></div>
			<?} else {?>
			<div class="thermometer" data-percent="0"></div>
			<?}?>
			<p class="meter-point" style="top: 23px"><?=isset($data[date("Y-m-",strtotime($date)).$day]) ? number_format($data[date("Y-m-",strtotime($date)).$day]) : "----"?>円</p>
			</td>
			</tr>
			<?}?>
		</table>
		<div class="total" style="padding: 12px 0 30px; height: auto; margin-top: 10px;">
			<p class="sum" style="padding-left: calc(4.5% + 7px); float: left;">合計</p>
			<p class="point" style="padding-right: calc(4.5% + 12px); float: right;"><?=number_format($total)?>円</p>
		</div>
	</div>


	<script type="text/javascript" src="/common/js/goal_popup.js"></script>
	<div class="guide-setting<?= $isKnowTarget ? ' is-know' : '' ?>">
		<div class="guide-setting__modal"></div>
		<div id="popup-1" class="guide-popup">
			<p class="guide-popup__title">日別報酬ページについて</p>
			<p class="guide-popup__text">このページでは、稼ぎたい目標金額を設定し、獲得状況と目標達成状況をグラフで確認することができます。<br>
				<br>
				グラフには「今月の獲得ポイント」と「目標ポイント」の推移が表示されます。<br>
				<strong class="notice is_emphasis">斜め線の目標ポイントよりも、獲得ポイントが高ければ目標達成ペースです!!</strong></p>
			<a class="guide-popup__button" data-num="1" href="javascript:void(0);">次へ</a>
		</div>
		<div id="popup-2" class="guide-popup scale-0">
			<p class="guide-popup__title">日別報酬ページについて</p>
			<div class="guide-popup-image-wrap">
				<img class="guide-popup__image" src="/secret/img/goal_guide_l.png" alt="">
			</div>
			<p class="guide-popup__text">目標を設定して、自分の限界にチャレンジしてみましょう♪<br><br>※目標金額にまよったら、まずは「5万円」を目指して頑張りましょう。</p>
			<a class="guide-popup__button" data-num="2" href="javascript:void(0);">次へ</a>
		</div>
		<div id="popup-3" class="guide-popup scale-0">
			<p class="guide-popup__title">目標設定</p>
			<form class="grade-select-wrap" action="" method="POST">
				<?php foreach ($targets as $id => $target) : ?>
				<?php
                    $is_active = false;
                    if ($hasTargetSetting) {
                        if ($targetSettings['type'] == POINT_TARGET_TYPE_SCALE && $id == $targetSettings['value']) {
                            $is_active = true;
                        }
                    } else {
                        if ($id == POINT_TARGET_SCALE_RECOMMEND) {
                            $is_active = true;
                        }
                    }
                ?>
				<label class="grade-select<?= $is_active ? ' is-active' : '' ?>" for="r<?= $id ?>" onclick="null" data-type="<?php echo POINT_TARGET_TYPE_SCALE ?>">
					<span class="grade-select__check"></span>
					<p class="grade-select__name"><input id="r<?= $id ?>" type="radio" name="target[<?php echo POINT_TARGET_TYPE_SCALE ?>]" value="<?= $id ?>"<?= $is_active ? ' checked="checked"' : '' ?>>
						<?= $target['label'] ?><span class="grade-select__number">（<?= $target['value'] ?>倍）</span>
					</p>
				</label>
				<?php endforeach; ?>

				<div>
					<?php
                        $is_active = ($hasTargetSetting && $targetSettings['type'] == POINT_TARGET_TYPE_POINT) ? true : false;
                    ?>
					<label class="grade-select<?= $is_active ? ' is-active' : '' ?>" for="rt" onclick="null" data-type="<?php echo POINT_TARGET_TYPE_POINT ?>">
						<span class="grade-select__check"></span>
						<p class="grade-select__name"><input id="rt" type="radio">自分で入力する</p>
					</label>
					<input class="grade-select__input grade-select__manual" type="text" name="target[<?php echo POINT_TARGET_TYPE_POINT ?>]" value="<?= $is_active ? $targetSettings['value'] : '' ?>" placeholder="半角英数字で入力"<?= !$is_active ? ' disabled' : '' ?>>
					<span style="color: #4a4a4a">pts</span>
					<div class="manual__errors hidden">
						<p class="less">目標金額が低すぎます。</p>
						<p class="greater">目標金額が高すぎます。</p>
					</div>
				</div>
				<input class="grade-select__button" type="submit" name="" value="登録" style="width: 80%;">
			</form>

		</div>
	</div>
	<?}?>
</section>
<script>
	<?php if($this->_sdk->canTrackingRepro()) :?>
	window.repro = window.repro || {};
	// window.repro.isInAppBrowser = /NTQ_CUSTOM_USER_AGENT/.test(navigator.userAgent);
	$( document ).ready(function() {
		repro.track("view_reward_daily");
	});
	<?php endif; ?>
</script>
<?include_once _FEMALE_TEMPLATES_PATH .'common/menu.tpl'?>
<?include_once _FEMALE_TEMPLATES_PATH .'common/footer.tpl'?>
