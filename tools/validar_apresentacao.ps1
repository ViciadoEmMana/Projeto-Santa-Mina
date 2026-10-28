param([string]$Godot = 'godot')
# Executa as suítes reais, guarda logs no temporário e exige resultado explícito.
$raizValidacaoSantaMina = Split-Path -Parent $PSScriptRoot
$suitesSantaMina = @('teste_brokk','teste_campanha','teste_cartas','teste_atualizacao','teste_interacao_layout','teste_brokk_visual','teste_brokk_complementos','teste_arqueiro_visual','teste_porrete_visual','teste_visuais_campanha','teste_salvamento','teste_arena_interface','teste_faca_cega','teste_zeno')
$totalVerificacoesSantaMina = 0
foreach ($suiteSantaMina in $suitesSantaMina) {
    $arquivoLogSantaMina = Join-Path $env:TEMP ('santa-mina-final-' + $suiteSantaMina + '.log')
    $saidaSantaMina = (& $Godot --headless --path $raizValidacaoSantaMina --audio-driver Dummy --log-file $arquivoLogSantaMina --script ('res://tests/' + $suiteSantaMina + '.gd') 2>&1 | Out-String)
    $codigoSaidaSantaMina = $LASTEXITCODE
    $resultadoSantaMina = [regex]::Match($saidaSantaMina, 'RESULTADO[^\r\n]*?(\d+) verificações, (\d+) falhas\.')
    if ($codigoSaidaSantaMina -ne 0 -or -not $resultadoSantaMina.Success -or $resultadoSantaMina.Groups[2].Value -ne '0' -or $saidaSantaMina.Contains('SCRIPT ERROR:')) {
        Write-Output $saidaSantaMina
        throw ('Falha em ' + $suiteSantaMina + '. Consulte ' + $arquivoLogSantaMina)
    }
    $totalVerificacoesSantaMina += [int]$resultadoSantaMina.Groups[1].Value
    Write-Output ($suiteSantaMina + ': ' + $resultadoSantaMina.Value)
}
# A segunda execução deve ler o arquivo deixado por um processo já encerrado.
$slotProcessosSantaMina = Join-Path $env:TEMP ('santa-mina-reinicio-' + [guid]::NewGuid().ToString('N') + '.json')
foreach ($modoSaveSantaMina in @('gravar', 'ler')) {
    $logSaveSantaMina = Join-Path $env:TEMP ('santa-mina-final-save-' + $modoSaveSantaMina + '.log')
    $saidaSaveSantaMina = (& $Godot --headless --path $raizValidacaoSantaMina --audio-driver Dummy --log-file $logSaveSantaMina --script 'res://tests/teste_salvamento_processos.gd' -- $modoSaveSantaMina $slotProcessosSantaMina 2>&1 | Out-String)
    $codigoSaveSantaMina = $LASTEXITCODE
    $resultadoSaveSantaMina = [regex]::Match($saidaSaveSantaMina, 'RESULTADO[^\r\n]*?(\d+) verificações, (\d+) falhas\.')
    if ($codigoSaveSantaMina -ne 0 -or -not $resultadoSaveSantaMina.Success -or $resultadoSaveSantaMina.Groups[2].Value -ne '0' -or $saidaSaveSantaMina.Contains('SCRIPT ERROR:')) {
        Write-Output $saidaSaveSantaMina
        throw ('Falha em save entre processos: ' + $modoSaveSantaMina)
    }
    $totalVerificacoesSantaMina += [int]$resultadoSaveSantaMina.Groups[1].Value
    Write-Output ('save entre processos (' + $modoSaveSantaMina + '): ' + $resultadoSaveSantaMina.Value)
}
$hashesSantaMina = @{
    'tabuleiro.gd' = '905F563D6CE22751A65FC7E574A085D3A9A1531388E256A8E8E95DF723A4030F'
    'cena_principal.tscn' = '9EB3BD6FD152AC77910677D13BF01970EB5E90C0FB6FF8738C1E31BC977C4B8E'
    'project.godot' = 'DB4B1C37A920C32E947EAA332F5EA62AD0399F6A2E5A080A3FBF284CA4EB3D7E'
}
foreach ($arquivoSantaMina in $hashesSantaMina.Keys) {
    $hashAtualSantaMina = (Get-FileHash -LiteralPath (Join-Path $raizValidacaoSantaMina $arquivoSantaMina) -Algorithm SHA256).Hash
    if ($hashAtualSantaMina -ne $hashesSantaMina[$arquivoSantaMina]) { throw ('Arquivo protegido foi alterado: ' + $arquivoSantaMina) }
}
Write-Output ('TOTAL FINAL: ' + $totalVerificacoesSantaMina + ' verificações, 0 falhas. Tabuleiro, cena principal e configuração preservados.')
