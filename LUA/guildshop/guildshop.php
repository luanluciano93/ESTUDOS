<?php require_once 'engine/init.php';
include 'layout/overall/header.php';

if (isset($_GET['callback']) && $_GET['callback'] === 'processing') {
	echo '<script>alert("Seu pagamento está sendo processado pelo PagSeguro...");</script>';
}

// Import from config:
$shop = $config['guild_shop'];
if ($shop['loginToView'] === true) protect_page();
$loggedin = user_logged_in();

$shop_list = $config['guild_shop_offers'];

if ($shop['enabled']) {
?>
<div class="title"> <h1> Guild Shop Offers</h1> </div>
<?php
if ($loggedin === true) {
	if (!empty($_POST['buy']) && $_SESSION['shop_session'] == $_POST['session']) {
		$time = time();
		$player_points = (int)$user_znote_data['guild_points'];
		$cid = (int)$user_data['id'];
		// Sanitizing post, setting default buy value
		$buy = false;
		$post = (int)$_POST['buy'];

		foreach ($shop_list as $key => $value) {
			if ($key === $post) {
				$buy = $value;
			}
		}
		if ($buy === false) die("Error: Guild shop offer ID mismatch.");

		// Verify that user can afford this offer.
		if ($player_points >= $buy['guild_points']) {
			$data = mysql_select_single("SELECT `guild_points` FROM `znote_accounts` WHERE `account_id`='$cid';");
			if (!$data) die("0: Account is not converted to work with Znote AAC");
			$old_points = $data['guild_points'];
			if ((int)$old_points != (int)$player_points) die("1: Failed to equalize your guild points.");
			// Remove guild points if they can afford
			// Give guild points to user
			$expense_points = $buy['guild_points'];
			$new_points = $old_points - $expense_points;
			$update_account = mysql_update("UPDATE `znote_accounts` SET `guild_points`='$new_points' WHERE `account_id`='$cid'");

			$data = mysql_select_single("SELECT `guild_points` FROM `znote_accounts` WHERE `account_id`='$cid';");
			$verify = $data['guild_points'];
			if ((int)$old_points == (int)$verify) die("2: Failed to equalize your guild points.". var_dump((int)$old_points, (int)$verify, $new_points, $expense_points));

			// If this is an outfit offer, convert array into an integer.
			if ($buy['type'] == 5) {
				if (is_array($buy['itemid'])) {
					if (COUNT($buy['itemid']) == 2) $buy['itemid'] = ($buy['itemid'][0] * 1000) + $buy['itemid'][1];
					else $buy['itemid'] = $buy['itemid'][0];
				}
			}

			// Do the magic (insert into db, or change sex etc)
			// If type is 2 or 3
			if ($buy['type'] == 2) {
				// Add premium days to account
				user_account_add_premdays($cid, $buy['count']);
				echo '<font color="green" size="4">You now have '.$buy['count'].' additional days of premium membership.</font>';
			} else if ($buy['type'] == 3) {
				// Character Gender
				mysql_insert("INSERT INTO `znote_shop_orders` (`account_id`, `type`, `itemid`, `count`, `time`) VALUES ('$cid', '". $buy['type'] ."', '". $buy['itemid'] ."', '". $buy['count'] ."', '$time')");
				echo '<p><font color="green" size="4">You now have access to change character gender on your characters. Visit <a href="myaccount.php">My Account</a> to select character and change the gender.</font></p>';
			} else if ($buy['type'] == 4) {
				// Character Name
				mysql_insert("INSERT INTO `znote_shop_orders` (`account_id`, `type`, `itemid`, `count`, `time`) VALUES ('$cid', '". $buy['type'] ."', '". $buy['itemid'] ."', '". $buy['count'] ."', '$time')");
				echo '<p><font color="green" size="4">You now have access to change character name on your characters. Visit <a href="myaccount.php">My Account</a> to select character and change the name.</font></p>';
			} else {
				mysql_insert("INSERT INTO `znote_shop_orders` (`account_id`, `type`, `itemid`, `count`, `time`) VALUES ('$cid', '". $buy['type'] ."', '". $buy['itemid'] ."', '". $buy['count'] ."', '$time')");
				echo '<p><font color="green" size="4">Your order is ready to be delivered. Write this command in-game to get it: [!shop].<br>Make sure you are in depot and can carry it before executing the command!</font></p>';
			}

			// No matter which type, we will always log it.
			mysql_insert("INSERT INTO `znote_shop_logs` (`account_id`, `player_id`, `type`, `itemid`, `count`, `points`, `time`) VALUES ('$cid', '0', '". $buy['type'] ."', '". $buy['itemid'] ."', '". $buy['count'] ."', '". $buy['guild_points'] ."', '$time')");

		} else echo '<p><font color="red" size="4">You need more guild points, this offer cost '.$buy['guild_points'].' points.</font></p>';
		//var_dump($buy);
		//echo '<font color="red" size="4">'. $_POST['buy'] .'</font>';
	}
}

if ($loggedin === true) {
	if (!empty($_POST['buy']) && $_SESSION['shop_session'] == $_POST['session']) {
		if ($user_znote_data['guild_points'] >= $buy['guild_points']) {
			?><p><b><font color="red">You have <?php echo (int)($user_znote_data['guild_points'] - $buy['guild_points']); ?> guild points.</font></b></p><?php
		} else {
			?><p><b><font color="red">You have <?php echo $user_znote_data['guild_points']; ?> guild points.</font></b></p><?php
		}
	} else {
		?><p><b><font color="red">You have <?php echo $user_znote_data['guild_points']; ?> guild points.</font></b></p><?php
	}
} else {
	?><p>You need to be logged in to use the guild shop.</p><?php
}

?>
<table class="table tbl-hover">
	<thead>
		<tr class="yellow">
			<td colspan="2"><center>Guild Shop System</center></td>
		</tr>
	</thead>
	<tbody>
		<tr> <td> <center>Comando Utilizado:</center> </td> <td> <b> !guildpoints (leader)</b> </td> </tr>
		<tr> <td> <center>Level Mínimo:</center> </td> <td> <b>	Level 80+</b> </td> </tr>
		<tr> <td> <center>Players Online:</center> </td> <td> <b> 4 Online</b> </td> </tr>
		<tr> <td> <center>IPs Diferentes:</center> </td> <td> <b>	4 IPs</b> </td> </tr>
		<tr> <td> <center>Quantidade de Pontos:</center> </td> <td> <b>	10 Pontos (cada player)</b> </td> </tr>
		<tr> <td> <center>Obs:</center> </td> <td> <b> O benefício só poderá ser adquirido uma vez por account. </b> </td> </tr>
	</tbody>
</table>

<?php
$outfitsIds = array(136,137,138,139,140,141,142,147,148,149,150,155,156,157,158,252,269,270,279,288,324,336,366,431,433,464,466,471,513,514,542,128,129,130,131,132,133,134,143,144,145,146,151,152,153,154,251,268,273,278,289,325,335,367,430,432,463,465,472,512,516,541);
$category_items = array();
$category_premium = array();
$category_outfits = array();
$category_mounts = array();
$category_misc = array();
foreach ($shop_list as $key => $offer) {

	switch ($offer['type']) {
		case 1:
			$category_items[$key] = $offer;
		break;
		case 2:
			$category_premium[$key] = $offer;
		break;
		case 3:
			$category_misc[$key] = $offer;
		break;
		case 4:
			$category_misc[$key] = $offer;
		break;
		case 5:
			$category_outfits[$key] = $offer;
		break;
		case 6:
			$category_mounts[$key] = $offer;
		break;
		default:
			$category_misc[$key] = $offer;
		break;
	}
}

// Render a bunch of tables (one for each category)
?>
<div id="categoryNavigator">
	<a class="nav_link" href="#all">ALL</a>
	<?php if (!empty($category_premium)): ?><a class="nav_link" href="#cat_premium">PREMIUM</a><?php endif; ?>
	<?php if (!empty($category_misc)): ?><a class="nav_link" href="#cat_misc">MISC</a><?php endif; ?>
	<?php if (!empty($category_items)): ?><a class="nav_link" href="#cat_itemids">ITEMS</a><?php endif; ?>
	<?php if (!empty($category_outfits)): ?><a class="nav_link" href="#cat_outfits">OUTFITS</a><?php endif; ?>
	<?php if (!empty($category_mounts)): ?><a class="nav_link" href="#cat_mounts">MOUNTS</a><?php endif; ?>
</div>
<script type="text/javascript">
	function domReady () {
		var links = document.getElementsByClassName("nav_link");
		for (var i=0; i < links.length; i++) {
			links[i].addEventListener('click', function(e){
				e.preventDefault();
				// Hide all tables
				for (var x=0; x < links.length; x++) {
					var hash = links[x].hash.substr(1);
					if (hash != 'all') {
						var table = document.getElementById(hash);
						if (table.classList.contains("show")) {
							table.classList.remove("show");
							table.classList.add("hide");
						}
					}
				}
				// Display only the one we selected
				var hash = this.hash.substr(1);
				if (hash != 'all') {
					var target = document.getElementById(hash);
					if (target.classList.contains('hide')) {
						target.classList.remove("hide");
						target.classList.add("show");
					}
				} else { // We clicked to show all tables
					// Show all tables
					for (var x=0; x < links.length; x++) {
						var hash = links[x].hash.substr(1);
						if (hash != 'all') {
							var table = document.getElementById(hash);
							if (table.classList.contains("hide")) {
								table.classList.remove("hide");
								table.classList.add("show");
							}
						}
					}
				}
			});
		}
	}
	// Mozilla, Opera, Webkit
	if ( document.addEventListener ) {
		document.addEventListener( "DOMContentLoaded", function(){
		document.removeEventListener( "DOMContentLoaded", arguments.callee, false);
		domReady();
	  }, false );
	// If IE event model is used
	} else if ( document.attachEvent ) {
		// ensure firing before onload
		document.attachEvent("onreadystatechange", function(){
		if ( document.readyState === "complete" ) {
			document.detachEvent( "onreadystatechange", arguments.callee );
			domReady();
		}
		});
	}
</script>


<?php if (!empty($category_premium)): ?>
<!-- PREMIUM DURATION -->
<table class="show" id="cat_premium">
	<tr class="yellow">
		<td>Description:</td>
		<?php if ($config['guild_shop']['showImage']) { ?><td>Image:</td><?php } ?>
		<td>Duration:</td>
		<td>Guild Points:</td>
		<?php if ($loggedin === true): ?><td>Action:</td><?php endif; ?>
	</tr>
	<?php foreach ($category_premium as $key => $offers): ?>
		<tr class="special">
			<td><?php echo $offers['description']; ?></td>
			<?php if ($config['guild_shop']['showImage']):?>
				<td><img src="images/shop/premium.gif" alt="premium scroll"></td>
			<?php endif; ?>
			<td><?php echo $offers['count']; ?> Days</td>
			<td><?php echo $offers['guild_points']; ?></td>
			<?php if ($loggedin === true): ?>
			<td>
				<form action="" method="POST">
					<input type="hidden" name="buy" value="<?php echo (int)$key; ?>">
					<input type="hidden" name="session" value="<?php echo time(); ?>">
					<input type="submit" value="  PURCHASE  "  class="needconfirmation" data-item-name="<?php echo $offers['description']; ?>" data-item-cost="<?php echo $offers['guild_points']; ?>">
				</form>
			</td>
			<?php endif; ?>
		</tr>
	<?php endforeach; ?>
</table>
<?php endif; ?>
<?php if (!empty($category_misc)): ?>
<!-- MISCELLANEOUS -->
<table class="show" id="cat_misc">
	<tr class="yellow">
		<td>Description:</td>
		<?php if ($config['guild_shop']['showImage']) { ?><td>Image:</td><?php } ?>
		<td>Count/duration:</td>
		<td>Guild Points:</td>
		<?php if ($loggedin === true): ?><td>Action:</td><?php endif; ?>
	</tr>
	<?php foreach ($category_misc as $key => $offers): ?>
		<tr class="special">
			<td><?php echo $offers['description']; ?></td>
			<?php if ($config['guild_shop']['showImage']):?>
				<td><img src="images/shop/<?php echo $offers['itemid']; ?>.gif" alt="<?php echo $offers['description']; ?>"></td>
			<?php endif;
			if ($offers['count'] === 0): ?>
				<td>Unlimited</td>
			<?php else: ?>
				<td><?php echo $offers['count']; ?>x</td>
			<?php endif; ?>
			<td><?php echo $offers['guild_points']; ?></td>
			<?php if ($loggedin === true): ?>
			<td>
				<form action="" method="POST">
					<input type="hidden" name="buy" value="<?php echo (int)$key; ?>">
					<input type="hidden" name="session" value="<?php echo time(); ?>">
					<input type="submit" value="  PURCHASE  "  class="needconfirmation" data-item-name="<?php echo $offers['description']; ?>" data-item-cost="<?php echo $offers['guild_points']; ?>">
				</form>
			</td>
			<?php endif; ?>
		</tr>
	<?php endforeach; ?>
</table>
<?php endif; ?>
<?php if (!empty($category_items)): ?>
	<!-- ITEMIDS -->
	<table class="show" id="cat_itemids">
		<tr class="yellow">
			<td>Item:</td>
			<?php if ($config['guild_shop']['showImage']) { ?><td>Image:</td><?php } ?>
			<td>Count:</td>
			<td>Guild Points:</td>
			<?php if ($loggedin === true): ?><td>Action:</td><?php endif; ?>
		</tr>
		<?php foreach ($category_items as $key => $offers): ?>
			<tr class="special">
				<td><?php echo $offers['description']; ?></td>
				<?php if ($config['guild_shop']['showImage']):?>
					<td><img src="images/shop/<?php echo $offers['itemid']; ?>.gif" alt="<?php echo $offers['description']; ?>"></td>
				<?php endif; ?>
				<td><?php echo $offers['count']; ?>x</td>
				<td><?php echo $offers['guild_points']; ?></td>
				<?php if ($loggedin === true): ?>
				<td>
					<form action="" method="POST">
						<input type="hidden" name="buy" value="<?php echo (int)$key; ?>">
						<input type="hidden" name="session" value="<?php echo time(); ?>">
						<input type="submit" value="  PURCHASE  "  class="needconfirmation" data-item-name="<?php echo $offers['description']; ?>" data-item-cost="<?php echo $offers['guild_points']; ?>">
					</form>
				</td>
				<?php endif; ?>
			</tr>
		<?php endforeach; ?>
	</table>
<?php endif; ?>
<?php if (!empty($category_outfits)): ?>
<!-- OUTFITS -->
<table class="show" id="cat_outfits">
	<tr class="yellow">
		<td>Description:</td>
		<?php if ($config['guild_shop']['showImage']) { ?><td>Image:</td><?php } ?>
		<td>Guild Points:</td>
		<?php if ($loggedin === true): ?><td>Action:</td><?php endif; ?>
	</tr>
	<?php foreach ($category_outfits as $key => $offers):
		if (!is_array($offers['itemid'])) $offers['itemid'] = [$offers['itemid']];
		if (COUNT($offers['itemid']) > 2): ?>
			<tr class="special">
				<td colspan="2">
					<p><strong>Error:</strong> Outfit offer don't support more than 2 outfits. <?php echo COUNT($offers['itemid']); ?> configured.
						<br>[<?php echo implode(',', $offers['itemid']); ?>]</p>
				</td>
			</tr>
		<?php endif; ?>
		<tr class="special">
			<td><?php echo $offers['description']; ?></td>
			<?php if ($config['show_outfits']['shop']):?>
				<td><?php foreach($offers['itemid'] as $outfitId): ?>
					<img src="images/shop/<?php echo $outfitId; ?>.gif" alt="outfit <?php echo $outfitId; ?>">
				<?php endforeach; ?></td>
			<?php endif; ?>
			<td><?php echo $offers['guild_points']; ?></td>
			<?php if ($loggedin === true): ?>
			<td>
				<form action="" method="POST">
					<input type="hidden" name="buy" value="<?php echo (int)$key; ?>">
					<input type="hidden" name="session" value="<?php echo time(); ?>">
					<input type="submit" value="  PURCHASE  "  class="needconfirmation" data-item-name="<?php echo $offers['description']; ?>" data-item-cost="<?php echo $offers['guild_points']; ?>">
				</form>
			</td>
			<?php endif; ?>
		</tr>
	<?php endforeach; ?>
</table>
<?php endif; ?>
<?php if (!empty($category_mounts)): ?>
<!-- MOUNTS -->
<table class="show" id="cat_mounts">
	<tr class="yellow">
		<td>Description:</td>
		<?php if ($config['show_outfits']['shop']) { ?><td>Image:</td><?php } ?>
		<td>Guild Points:</td>
		<?php if ($loggedin === true): ?><td>Action:</td><?php endif; ?>
	</tr>
	<?php foreach ($category_mounts as $key => $offers): ?>
		<tr class="special">
			<td><?php echo $offers['description']; ?></td>
			<?php if ($config['guild_shop']['showImage']):?>
				<td><img src="<?php echo $config['show_outfits']['imageServer']; ?>?id=<?php echo $outfitsIds[rand(0,count($outfitsIds)-1)]; ?>&addons=<?php echo rand(1, 3); ?>&head=<?php echo rand(1, 132); ?>&body=<?php echo rand(1, 132); ?>&legs=<?php echo rand(1, 132); ?>&feet=<?php echo rand(1, 132); ?>&mount=<?php echo $offers['itemid']; ?>&direction=2" alt="img"></td>
			<?php endif; ?>
			<td><?php echo $offers['guild_points']; ?></td>
			<?php if ($loggedin === true): ?>
			<td>
				<form action="" method="POST">
					<input type="hidden" name="buy" value="<?php echo (int)$key; ?>">
					<input type="hidden" name="session" value="<?php echo time(); ?>">
					<input type="submit" value="  PURCHASE  "  class="needconfirmation" data-item-name="<?php echo $offers['description']; ?>" data-item-cost="<?php echo $offers['guild_points']; ?>">
				</form>
			</td>
			<?php endif; ?>
		</tr>
	<?php endforeach; ?>
</table>
<?php endif; ?>

<?php if ($shop['enableShopConfirmation']) { ?>
<script src="https://code.jquery.com/jquery-latest.min.js" type="text/javascript"></script>
<script>
	$(document).ready(function(){
		$(".needconfirmation").each(function(e){
			$(this).click(function(e){
				var itemname = $(this).attr("data-item-name");
				var itemcost = $(this).attr("data-item-cost");
				var r = confirm("Do you really want to purchase "+itemname+" for "+itemcost+" guild points?")
				if(r == false){
					e.preventDefault();
				}
			});
		});
	});
</script>
<?php }

	// Store current timestamp to prevent page-reload from processing old purchase
	$_SESSION['shop_session'] = time();

} else echo '<div class="title"> <h1> Guild Shop disabled </h1> </div> <p>Sorry, this functionality is disabled.</p>';
include 'layout/overall/footer.php'; ?>
