<?php require_once 'engine/init.php'; 
include 'layout/overall/header.php'; ?>

<?php 
$bounties = mysql_select_multi('SELECT A.* , B.name AS hunted_by, C.name AS player_hunted, D.name AS killed_by FROM bounty_hunters AS A LEFT JOIN players AS B ON A.fp_id = B.id LEFT JOIN players AS C ON A.sp_id = C.id  LEFT JOIN players AS D ON A.k_id = D.id ORDER BY A.added DESC');
?>

<script type="text/javascript">
function show_hide(flip)
{
    var tmp = document.getElementById(flip);
    if(tmp)
        tmp.style.display = tmp.style.display == 'none' ? '' : 'none';
}
</script>
<a onclick="show_hide('commands'); return false;" style="cursor: pointer;">Click here to show the Instructions</a><br/>
<div id="commands" style="display: none;">
<table border="0" cellspacing="1" cellpadding="4" width="100%">
    <tr bgcolor="#505050"><td class="white"><b>Instructions<b></td></tr>
    <td><center><h2>Commands</h2>
    <b>!hunt [playername], [prize]</b><br>
    <small>Example: <b>!hunt GM Rodrigo, 500<br><br><font color="green">Money is added to your bank account automatically if you get a Bounty Kill.</font></small><br></center></td>
</table>
</div>

    <?php 
    if (empty($bounties) || $bounties === false) { 
    ?>
    <table border="0" cellspacing="1" cellpadding="4" width="100%">
        <tr bgcolor="#505050">
            <td class="white">
                <b>Bounty Hunters</b>
            </td>
        </tr>
        <tr bgcolor="#D4C0A1">
            <td><center>Currently there are no bounty hunter offer!</center></td>
        </tr>
    </table>
    <?php } else {
    ?>
   
<table border="0" cellspacing="1" cellpadding="4" width="100%">
    <tr bgcolor="#505050">
        <td class="white" width="10%"><center><b>Player Hunted</b></center></td>
        <td class="white" width="10%"><center><b>Reward</b></center></td>
        <td class="white" width="10%"><center><b>Hunted by</b></center></td>
        <td class="white" width="10%"><center><b>Killed by</b></center></td>
    </tr>
    <?php
    foreach ($bounties as $bounty) {
    if ($bounty['killed_by']){ 
            $killed_by = '<a href="characterprofile.php?name='.$bounty['killed_by'].'">'.$bounty['killed_by'].'</a>'; 
    } else { 
            $killed_by = 'Still Alive'; 
    } 
    $cost = round($bounty['prize'] / 1000, 2);
    ?>
    <tr bgcolor="#F1E0C6">
        <td class="white"><center><a href="characterprofile.php?name=<?php echo $bounty['player_hunted'] ?>"><?php echo $bounty['player_hunted'] ?></a></center></td>
        <td class="white"><center><b><?php echo $cost ?>k</b><br><small><?php echo $bounty['prize'] ?>gp</small></center></td>
        <td class="white"><center><a href="characterprofile.php?name=<?php echo $bounty['hunted_by'] ?>"><?php echo $bounty['hunted_by'] ?></a></center></td>
        <td class="white"><center><?php echo $killed_by ?></center></td>
    </tr> <?php } } ?>
</table>
       
<?php include 'layout/overall/footer.php'; ?>
