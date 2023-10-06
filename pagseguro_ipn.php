<?php
	// Buscar valores de configuracao
	include_once 'config/config.php';

	$pagseguro = $config['pagseguro'];
	$notificationCode = $_POST['notificationCode'];
	$notificationType = $_POST['notificationType'];

	// comment to show E_NOTICE [undefinied variable etc.], comment if you want make script and see all errors
	error_reporting(E_ALL ^ E_STRICT ^ E_NOTICE);

	// true = show sent queries and SQL queries status/status code/error message
	define('DEBUG_DATABASE', false);

	define('INITIALIZED', true);

	// if not defined before, set 'false' to load all normal
	if (!defined('ONLY_PAGE'))
		define('ONLY_PAGE', false);

	// check if site is disabled/requires installation
	include_once './system/load.loadCheck.php';

	// fix user data, load config, enable class auto loader
	include_once './system/load.init.php';

	// DATABASE
	include_once('./system/load.database.php');
	if (DEBUG_DATABASE) {
		Website::getDBHandle()->setPrintQueries(true);
	}

	function getValue($value) {
		return (!empty($value)) ? sanitize($value) : false;
	}

	// Fetch and sanitize POST and GET values
	function sanitize($data) {
		return htmlentities(strip_tags(mysql_znote_escape_string($data)));
		// ???????????????????????????????????????????????????????????????????????????????????????????????????????
	}

	// Util function to insert log
	function report($code, $details = '') {
		$connectedIp = $_SERVER['REMOTE_ADDR'];
		$details = getValue($details);
		$details .= '\nConnection from IP: '. $connectedIp;
		$insert_into_report = $SQL->query('INSERT INTO `pagseguro_notifications` VALUES (null, ' . $SQL->quote(getValue($code)) . ', ' . $SQL->quote($details) . ', CURRENT_TIMESTAMP)');
	}

	function VerifyPagseguroIPN($code) {
		global $pagseguro;
		$url = $pagseguro['urls']['ws'];

		$cURL = curl_init();
		curl_setopt($cURL, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($cURL, CURLOPT_SSL_VERIFYHOST, false);
		curl_setopt($cURL, CURLOPT_URL, 'https://' . $url . '/v3/transactions/notifications/' . $code . '?email=' . $pagseguro['email'] . '&token=' . $pagseguro['token']);
		curl_setopt($cURL, CURLOPT_HEADER, false);
		curl_setopt($cURL, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($cURL, CURLOPT_FORBID_REUSE, true);
		curl_setopt($cURL, CURLOPT_FRESH_CONNECT, true);
		curl_setopt($cURL, CURLOPT_CONNECTTIMEOUT, 30);
		curl_setopt($cURL, CURLOPT_TIMEOUT, 60);
		curl_setopt($cURL, CURLINFO_HEADER_OUT, true);
		curl_setopt($cURL, CURLOPT_HTTPHEADER, array(
			'Connection: close',
			'Expect: ',
		));
		$Response = curl_exec($cURL);
		$Status = (int)curl_getinfo($cURL, CURLINFO_HTTP_CODE);
		curl_close($cURL);

		$output = print_r($Response, true);
		if(empty($Response) OR !$Status){
			return null;
		}
		if(intval($Status / 100) != 2){
			return false;
		}
		return trim($Response);
	}

	// Send an empty HTTP 200 OK response to acknowledge receipt of the notification
	header('HTTP/1.1 200 OK');

	if(empty($notificationCode) || empty($notificationType)){
		report($notificationCode, 'notificationCode or notificationType is empty. Type: ' . $notificationType . ', Code: ' . $notificationCode);
		exit();
	}

	if ($notificationType !== 'transaction') {
		report($notificationCode, 'Unknown ' . $notificationType . ' notificationType');
		exit();
	}

	$rawPayment = VerifyPagseguroIPN($notificationCode);
	$payment = simplexml_load_string($rawPayment);
	$paymentStatus = (int) $payment->status;
	$paymentCode = sanitize($payment->code);

	report($notificationCode, $rawPayment);

	#############################################################

	$transaction = $SQL->query("SELECT `completed` FROM `pagseguro_transactions` WHERE `payment_code` = " . $paymentCode . "")->fetch();

	if ($transaction !== false) {

		$update = $SQL->query("UPDATE `pagseguro_transactions` SET `payment_status` = " . $paymentStatus . " WHERE `payment_code` = " . $paymentCode . "");

	} else {
		$completed = ($paymentStatus != 7) ? 0 : 1;
		$account_id = (int) $payment->reference;
		$item = $payment->items->item[0];
		$coins = $item->quantity;

		$price = $coins * ($pagseguro['price'] / 100)

		$insert_into = $SQL->query('INSERT INTO `pagseguro_transactions` VALUES (
		' . $SQL->quote($paymentCode) . ',
		' . $SQL->quote($account_id) . ',
		' . $SQL->quote($price) . ',
		' . $SQL->quote($coins) . ',
		' . $SQL->quote($paymentStatus) . ',
		' . $SQL->quote($completed) . ', 0)');
	}

	// Check that the payment_status is Completed
	if ($paymentStatus == 3 || $paymentStatus == 4) {

		$status = true;

		if ($transaction) {
			if ($transaction['completed'] == 1) {
				$status = false;
			}
		}

		if ($payment->grossAmount == 0.0) {
			$status = false; // Wrong ammount of money
		}

		$item = $payment->items->item[0];
		$coins = $item->quantity;

		$priceUnit = ($pagseguro['price'] / 100)

		if ($item->amount != $priceUnit) {
			$status = false;
		}

		if ($status) {
			// transaction log
			$update1 = $SQL->query("UPDATE `pagseguro_transactions` SET `completed` = 1 WHERE `payment_code` = " . $paymentCode . "");

			$account_id = (int) $payment->reference;

			// Process payment
			$data_account = $SQL->query("SELECT `coins` AS `old_coins` FROM `accounts` WHERE `id` = " . $account_id . "")->fetch();

			// Give points to user
			$new_coins = $data_account['old_coins'] + $item->quantity;
			$update2 = $SQL->query("UPDATE `accounts` SET `coins` = " . $new_coins . " WHERE `id` = " . $account_id . "");
		}

	} else if ($paymentStatus == 7) {
		$update = $SQL->query("UPDATE `pagseguro_transactions` SET `completed` = 1 WHERE `payment_code` = " . $paymentCode . "");
	}
?>
