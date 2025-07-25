<script lang="ts">
	import { get } from 'svelte/store';
	import { MENU_WIDE, BROWSER_MODE } from '@store/stores';
	import { PLAYER, PLAYER_VEHICLES, SELECTED_PLAYER } from '@store/players';
	import Header from '@components/Header.svelte';
	import Button from './components/Button.svelte';
	import { onMount } from 'svelte';
	import { SendNUI } from '@utils/SendNUI';
	import Spinner from '@components/Spinner.svelte';
	import Autofill from '@components/Autofill.svelte';
	import Modal from '@components/Modal.svelte';
	import Input from '@pages/Actions/components/Input.svelte';
	import ButtonGroup from './components/ButtonGroup.svelte';
	import ConfirmAction from './components/ConfirmAction.svelte';
	import GiveItemModal from './components/GiveItemModal.svelte';
	import ChangeGroupModal from './components/ChangeGroupModal.svelte';
	import { ReceiveNUI } from '@utils/ReceiveNUI';

	let showGroupModal = false;
	let groupType: 'job' | 'gang' = 'job';
	let showGiveItemModal = false;
	let showActionButton = false;
	let confirmText = '';
	let confirmAction: () => void = () => {};

	function confirmActionButton(text: string, action: () => void) {
		confirmText = text;
		confirmAction = () => {
			action();
			showActionButton = false;
		};
		showActionButton = true;
	}

	function send(data: string) {
		return () =>
		SendNUI('clickButton', {
			data,
			selectedData: { Player: { value: $SELECTED_PLAYER.id } },
		});
	}

	let search = '';
	let loading = false;
	let playersOnline = [];
	let playersOffline = [];
	let banPlayer = false;
	let kickPlayer = false;
	let warnPlayer = false;
	let selectedDataArray = {};
	let showMoneyModal = false;
	let isGivingMoney = true; // true = dar, false = remover
	let moneyType = 'cash';
	let moneyAmount = 0;

	let banData = [
		{ label: 'Permanente', value: '2147483647' },
		{ label: '10 Minutos', value: '600' },
		{ label: '30 Minutos', value: '1800' },
		{ label: '1 Hora', value: '3600' },
		{ label: '6 Horas', value: '21600' },
		{ label: '12 Horas', value: '43200' },
		{ label: '1 Dia', value: '86400' },
		{ label: '3 Dias', value: '259200' },
		{ label: '1 Semana', value: '604800' },
		{ label: '3 Semanas', value: '1814400' },
	];

	function SelectData(selectedData) {
		selectedDataArray[selectedData.id] = selectedData;
	}

	onMount(async () => {
		const browserMode = get(BROWSER_MODE);

		if (browserMode) {
			// Só em modo browser: escuta mock do debugData
			window.addEventListener('message', (event) => {
				if (!event.data?.action) return;

				switch (event.data.action) {
					case 'setPlayersData':
						playersOnline = event.data.data.filter((p) => p.online);
						playersOffline = event.data.data.filter((p) => !p.online);
						PLAYER.set(event.data.data);
						break;
				}
			});
		} else {
			// Ambiente normal no jogo (FiveM)
			try {
				loading = true;
				const players = await SendNUI('getPlayers');
				if (players) {
					playersOnline = players.filter((player) => player.online);
					playersOffline = players.filter((player) => !player.online);
					PLAYER.set(players);
				}
			} catch (error) {
				console.error('Erro ao carregar jogadores:', error);
			} finally {
				loading = false;
			}
		}
	});

	async function refreshAllPlayers() {
		const browserMode = get(BROWSER_MODE);

		if (browserMode) return; // modo mock não precisa recarregar real

		try {
			loading = true;
			const players = await SendNUI('getPlayers');
			if (players) {
				playersOnline = players.filter((player) => player.online);
				playersOffline = players.filter((player) => !player.online);
				PLAYER.set(players);

				// Atualiza o SELECTED_PLAYER se ainda existir
				if ($SELECTED_PLAYER) {
					const updated = players.find(p => p.id === $SELECTED_PLAYER.id);
					if (updated) {
						SELECTED_PLAYER.set({ ...updated });
						PLAYER_VEHICLES.set([...updated.vehicles ?? []]);
					} else {
						SELECTED_PLAYER.set(null);
					}
				}
			}
		} catch (error) {
			console.error('Erro ao recarregar jogadores:', error);
		} finally {
			loading = false;
		}
	}

	ReceiveNUI('refreshPlayers', () => {
		refreshAllPlayers();
	});

</script>


<div class="h-full w-[33vh] px-[2vh]">
	<Header
		title="Jogadores"
		hasSearch={true}
		hasLargeMenu={$MENU_WIDE}
		onSearchInput={(event) => (search = event.target.value)}
	/>
	<div class="flex justify-end m-4">
		<button
			class="flex items-center gap-2 bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded shadow transition duration-150 text-md"
			on:click={refreshAllPlayers}
			disabled={loading}
			title="Atualizar lista de jogadores"
		>
			<i class="fas fa-rotate"></i>
			<span class="hidden sm:inline">{loading ? 'Atualizando...' : 'Atualizar'}</span>
		</button>
	</div>
	<div class="w-full h-[84%] flex flex-col gap-[1vh] mt-[1vh] overflow-auto">
		{#if loading}
			<Spinner />
		{:else}
			<p class="font-medium text-[1.7vh]">Jogadores Online</p>
			{#if playersOnline && playersOnline.filter((player) => player.name.toLowerCase().includes(search.toLowerCase())).length === 0}
				<div class="text-accent text-center text-[1.7vh] font-medium mt-[1vh]">Nenhum jogador online encontrado.</div>
			{:else}
				{#each playersOnline.filter((player) => player.name.toLowerCase().includes(search.toLowerCase())) as player}
					<div class="flex items-center gap-[1vh]">
						<span class="text-green-500 text-[2.5vh]">🟢</span>
						<Button {player} />
					</div>
				{/each}

			{/if}

			<p class="font-medium text-[1.7vh] mt-[2vh]">Jogadores Offline</p>
			{#if playersOffline && playersOffline.filter((player) => player.name.toLowerCase().includes(search.toLowerCase())).length === 0}
				<div class="text-accent text-center text-[1.7vh] font-medium mt-[1vh]">Nenhum jogador offline encontrado.</div>
			{:else}
				{#each playersOffline.filter((player) => player.name.toLowerCase().includes(search.toLowerCase())) as player}
					<div class="flex items-center gap-[1vh]">
						<span class="text-red-500 text-[2.5vh]">🔴</span>
						<Button {player} />
					</div>
				{/each}

			{/if}
		{/if}
	</div>
</div>


{#if $MENU_WIDE}
  <div class="h-full w-[66vh] border-l-[0.2vh] border-tertiary p-[2vh] flex flex-col">
		{#if !$SELECTED_PLAYER}
			<div
				class="h-full w-full flex flex-col items-center justify-center"
			>
			<div class="text-4xl text-accent">Nenhum jogador selecionado.</div>
		</div>
		{:else}
			<p class="text-[2vh] font-medium">
				ID: {$SELECTED_PLAYER.id} - {$SELECTED_PLAYER.name}
				{#if $SELECTED_PLAYER.metadata?.verified}
					<span class="ml-2 bg-green-500 text-white px-2 py-0.5 rounded text-[1.2vh]">
						✅ Confiável
						{#if $SELECTED_PLAYER.metadata?.verified_by}
							por {$SELECTED_PLAYER.metadata.verified_by}
						{/if}
					</span>
				{:else}
					<span class="ml-2 bg-red-500 text-white px-2 py-0.5 rounded text-[1.2vh]">⛔ Suspeito</span>
				{/if}
			</p>

			<div class="w-full h-[96.5%] pt-[2vh] flex flex-col gap-[1vh] overflow-auto">
				<p class="font-medium text-[1.7vh]">Ações Rápidas</p>
				{#if $SELECTED_PLAYER.online}
					<ButtonGroup
						buttons={[
						{ icon: 'fa-solid fa-map-pin', label: 'Teleportar', onClick: send('teleportToPlayer') },
						{ icon: 'fas fa-person-walking-arrow-loop-left', label: 'Puxar', onClick: send('bringPlayer') },
						{ icon: 'fas fa-person-walking-arrow-right', label: 'Enviar de Volta', onClick: send('sendPlayerBack') },
						{ icon: 'fas fa-heart-pulse', label: 'Reviver', onClick: send('revivePlayer') }
						]}
					/>

					<p class="font-medium text-[1.7vh]">Gerenciamento</p>
					<ButtonGroup
						buttons={[
						{ icon: 'fa-solid fa-check', label: 'Confiável/Suspeito', onClick: send('verifyPlayer') },
						{
							icon: 'fa-solid fa-money-bill-wave',
							label: 'Dar Dinheiro',
							onClick: () => {
							isGivingMoney = true;
							showMoneyModal = true;
							},
						},
						{
							icon: 'fa-solid fa-money-bill-wave',
							label: 'Remover Dinheiro',
							onClick: () => {
							isGivingMoney = false;
							showMoneyModal = true;
							},
						},
						{ icon: 'fa-solid fa-shirt', label: 'Menu Roupas', onClick: send('clothing_menu') },
						]}
					/>

					<p class="font-medium text-[1.7vh]">Segurança</p>
					<ButtonGroup
						buttons={[
						{ icon: 'fas fa-eye', label: 'Espectar', onClick: send('spectate_player') },
						{ icon: 'fa-solid fa-triangle-exclamation', label: 'Advertência', onClick: () => (warnPlayer = true) },
						{ icon: 'fas fa-user-slash', label: 'Kickar', onClick: () => (kickPlayer = true) },
						{ icon: 'fas fa-ban', label: 'Banir', onClick: () => (banPlayer = true) },
						]}
					/>

					<ButtonGroup
						buttons={[
						{ icon: 'fa-solid fa-handcuffs', label: 'Algemar/Desalgemar', onClick: send('toggle_cuffs') },
						{ icon: 'fa-solid fa-snowflake', label: 'Congelar/Descongelar', onClick: send('freeze_player') },
						{ icon: 'fa-solid fa-skull-crossbones', label: 'Matar', onClick: send('kill_player') },
						{ 
							icon: 'fa-solid fa-circle-check', 
							label: 'Desbanir', 
							onClick: () =>
								confirmActionButton('Deseja realmente desbanir o jogador?', () => {
									SendNUI('clickButton', {
										data: 'unbanPlayer',
										selectedData: {
										Player: { value: $SELECTED_PLAYER.id }
										}
									});
								})
							},
						]}
					/>

					<p class="font-medium text-[1.7vh]">Grupos</p>
					<ButtonGroup
						buttons={[
							{ icon: 'fa-solid fa-user-tie', label: 'Definir Emprego', 
							  	onClick: () => {
									groupType = 'job';
									showGroupModal = true;
								}
							},
							{
								icon: 'fa-solid fa-user-xmark',
								label: 'Remover Emprego',
								onClick: () =>
									confirmActionButton('Deseja realmente remover o jogador do emprego?', () => {
										SendNUI('clickButton', {
											data: 'fire_job',
											selectedData: {
												Player: { value: $SELECTED_PLAYER.id },
												Job: { value: 'unemployed' },
												Grade: { value: 0 },
											}
										});
									})
							},
							{ icon: 'fa-solid fa-users', label: 'Definir Gangue', 
								onClick: () => {
									groupType = 'gang';
									showGroupModal = true;
								}
							},
							{
								icon: 'fa-solid fa-users-slash',
								label: 'Demitir Gangue',
								onClick: () =>
									confirmActionButton('Deseja realmente remover o jogador da gangue?', () => {
										SendNUI('clickButton', {
											data: 'fire_gang',
											selectedData: {
												Player: { value: $SELECTED_PLAYER.id },
												Gang: { value: 'none' },
												Grade: { value: 0 },
											}
										});
									})
							}
						]}
					/>

					<p class="font-medium text-[1.7vh]">Inventário</p>
					<ButtonGroup
						buttons={[
							{
								icon: 'fa-solid fa-share-from-square',
								label: 'Dar item',
								onClick: () => {
									showGiveItemModal = true;
								},
							},
							{ icon: 'fa-solid fa-box-open', label: 'Abrir Inventário', onClick: send('open_inventory') },
							{
							icon: 'fa-solid fa-hand-sparkles',
							label: 'Limpar Inventário',
							onClick: () =>
								confirmActionButton('Deseja realmente limpar o inventário?', () => {
									SendNUI('clickButton', {
										data: 'clear_inventory',
										selectedData: {
											Player: { value: $SELECTED_PLAYER.id }
										}
									});
								})
							},
						]}
					/>

				{:else}
					<p class="text-center text-[1.5vh] text-accent">Jogador offline - as ações foram limitadas</p>
					<ButtonGroup
						buttons={[
						{ 
							icon: 'fa-solid fa-skull-crossbones',
							label: 'Excluir Personagem', 
							onClick: () =>
								confirmActionButton('Deseja realmente excluir o personagem do jogador?', () => {
									SendNUI('clickButton', {
										data: 'delete_cid',
										selectedData: {
										cid: { value: $SELECTED_PLAYER.cid }
										}
									});
								})
							},
						{ 
							icon: 'fa-solid fa-circle-check', 
							label: 'Desbanir', 
							onClick: () =>
								confirmActionButton('Deseja realmente desbanir o jogador?', () => {
									SendNUI('clickButton', {
										data: 'unban_cid',
										selectedData: {
										cid: { value: $SELECTED_PLAYER.cid }
										}
									});
								})
							},
						]}
					/>
				{/if}
				<div
					class="h-[100%] flex flex-col gap-[1vh] select-text"
				>
					<p class="font-medium text-[1.7vh]">Licenças</p>
					<div
						class="w-full bg-tertiary rounded-[0.5vh] p-[1.5vh] text-[1.5vh]"
					>
						<p>{ $SELECTED_PLAYER.discord 
							? $SELECTED_PLAYER.discord.replace('discord:', 'Discord: ') 
							: 'Discord: N/A'
						}</p>
						<p>{ $SELECTED_PLAYER.license 
							? $SELECTED_PLAYER.license.replace('license:', 'License: ') 
							: 'License: N/A'
						}</p>

						<p>
							{$SELECTED_PLAYER.fivem
								? $SELECTED_PLAYER.fivem
								: ''}
						</p>

						<p>
							{$SELECTED_PLAYER.steam
								? $SELECTED_PLAYER.steam
								: ''}
						</p>
					</div>
					<p class="font-medium text-[1.7vh]">Informação</p>
					<div
						class="w-full bg-tertiary rounded-[0.5vh] p-[1.5vh] text-[1.5vh]"
					>
						<p>RG: {$SELECTED_PLAYER.cid}</p>
						<p>Nome: {$SELECTED_PLAYER.name}</p>
						<p>Job: {$SELECTED_PLAYER.job ?? 'N/A'} ({$SELECTED_PLAYER.job_grade ?? '0'})</p>
						<p>Gangue: {$SELECTED_PLAYER.gang ?? 'N/A'} ({$SELECTED_PLAYER.gang_grade ?? '0'})</p>
						<p>Carteira: R$ {$SELECTED_PLAYER.cash}</p>
						<p>Banco: R$ {$SELECTED_PLAYER.bank}</p>
						<p>Telefone: {$SELECTED_PLAYER.phone}</p>
						<p>Verificado: {$SELECTED_PLAYER.phone}</p>
					</div>
					<p class="font-medium text-[1.7vh]">Veículos</p>
					{#each $SELECTED_PLAYER.vehicles ?? [] as vehicle}
						<div
							class="w-full bg-tertiary flex flex-row rounded-[0.5vh] p-[1.5vh] text-[1.5vh]"
						>
							<div>
								<p class=" font-medium text-[1.7vh]">
									{vehicle.label}
								</p>
								<p>Placa: {vehicle.plate}</p>
							</div>
							<div class="ml-auto h-full flex items-center gap-5">
								<button
									class="bg-secondary px-[1vh] py-[0.5vh] rounded-[0.5vh] border border-primary hover:bg-primary"
									on:click={() =>
										SendNUI('clickButton', {
											data: 'spawnPersonalVehicle',
											selectedData: {
												['VehiclePlate']: {
													value: vehicle.plate,
												},
											},
										})}
								>
									Spawnar
								</button>
								<button
									class="bg-secondary px-[1vh] py-[0.5vh] rounded-[0.5vh] border border-primary hover:bg-primary"
									on:click={() =>
										SendNUI('clickButton', {
											data: 'open_trunk',
											selectedData: {
												['Plate']: {
													value: vehicle.plate,
												},
											},
										})}
								>
									Porta-Malas
								</button>
								<button
									class="bg-red-500 px-[1vh] py-[0.5vh] rounded-[0.5vh] border border-primary hover:bg-red-600"
									on:click={() => {
										SendNUI('clickButton', {
											data: 'deletePersonalVehicle',
											selectedData: {
												['Plate']: {
													value: vehicle.plate,
												},
											},
										});
										setTimeout(() => {
											refreshAllPlayers();
										}, 500);
									}}
								>
									<i class="fa-solid fa-trash"></i> Permanente
								</button>
							</div>
						</div>
					{/each}
				</div>
			</div>
		{/if}
	</div>
{/if}

{#if banPlayer}
	<Modal>
		<div class="flex justify-between">
			<p class="font-medium text-[1.8vh]">Ban {$SELECTED_PLAYER.name}</p>
			<button
				class="hover:text-accent"
				on:click={() => (banPlayer = false)}
			>
				<i class="fas fa-xmark"></i>
			</button>
		</div>
		<Input
			data={{
				label: 'Reason',
				value: 'Reason',
				id: 'Reason',
			}}
			selectedData={SelectData}
		/>
		<Autofill
			action={{
				label: 'Duração',
				value: 'Duração',
				id: 'Duração',
			}}
			label_title="Duração"
			data={banData}
			selectedData={SelectData}
		/>
		<button
			class="h-[3.8vh] px-[1.5vh] rounded-[0.5vh] bg-secondary hover:bg-opacity-90 border-[0.1vh] border-primary"
			on:click={() => {
				// console.log('Time: ', selectedDataArray['Duração'].value)
				// console.log('reason: ', selectedDataArray['Reason'].value)
				SendNUI('clickButton', {
					data: 'banPlayer',
					selectedData: {
						['Player']: {
							value: $SELECTED_PLAYER.id,
						},
						['Duração']: {
							value: selectedDataArray['Duração'].value,
						},
						['Reason']: {
							value: selectedDataArray['Reason'].value,
						},
					},
				})
			}}
		>
			<p>Ban</p>
		</button>
	</Modal>
{/if}

{#if kickPlayer}
	<Modal>
		<div class="flex justify-between">
			<p class="font-medium text-[1.8vh]">Kick {$SELECTED_PLAYER.name}</p>
			<button
				class="hover:text-accent"
				on:click={() => (kickPlayer = false)}
			>
				<i class="fas fa-xmark"></i>
			</button>
		</div>
		<Input
			data={{
				label: 'Reason',
				value: 'Reason',
				id: 'Reason',
			}}
			selectedData={SelectData}
		/>
		<button
			class="h-[3.8vh] px-[1.5vh] rounded-[0.5vh] bg-secondary hover:bg-opacity-90 border-[0.1vh] border-primary"
			on:click={() => {
				SendNUI('clickButton', {
					data: 'kickPlayer',
					selectedData: {
						['Player']: {
							value: $SELECTED_PLAYER.id,
						},
						['Reason']: {
							value: selectedDataArray['Reason'].value,
						},
					},
				})
			}}
		>
			<p>Kick</p>
		</button>
	</Modal>
{/if}

{#if warnPlayer}
	<Modal>
		<div class="flex justify-between">
			<p class="font-medium text-[1.8vh]">Advertência {$SELECTED_PLAYER.name}</p>
			<button
				class="hover:text-accent"
				on:click={() => (warnPlayer = false)}
			>
				<i class="fas fa-xmark"></i>
			</button>
		</div>
		<Input
			data={{
				label: 'Reason',
				value: 'Reason',
				id: 'Reason',
			}}
			selectedData={SelectData}
		/>
		<button
			class="h-[3.8vh] px-[1.5vh] rounded-[0.5vh] bg-secondary hover:bg-opacity-90 border-[0.1vh] border-primary"
			on:click={() => {
				SendNUI('clickButton', {
					data: 'warn_player',
					selectedData: {
						['Player']: {
							value: $SELECTED_PLAYER.id,
						},
						['Reason']: {
							value: selectedDataArray['Reason'].value,
						},
					},
				})
			}}
		>
			<p>Enviar</p>
		</button>
	</Modal>
{/if}

{#if showMoneyModal}
	<Modal>
		<div class="flex justify-between items-center mb-[1vh]">
			<p class="font-medium text-[1.8vh]">
				{isGivingMoney ? 'Dar dinheiro' : 'Remover dinheiro'} para {$SELECTED_PLAYER.name}
			</p>
			<button on:click={() => (showMoneyModal = false)} class="hover:text-accent">
				<i class="fas fa-xmark"></i>
			</button>
		</div>

		<label class="text-[1.5vh] font-medium">Tipo:</label>
		<select bind:value={moneyType} class="w-full bg-tertiary rounded p-[1vh] mb-[1vh]">
			<option value="cash">Dinheiro</option>
			<option value="bank">Banco</option>
			<option value="crypto">Cripto</option>
		</select>

		<label class="text-[1.5vh] font-medium">Valor:</label>
		<input
			type="number"
			bind:value={moneyAmount}
			min="0"
			class="w-full bg-tertiary rounded p-[1vh] mb-[2vh] text-white"
			placeholder="Digite o valor"
		/>

		<button
			class="h-[3.8vh] px-[1.5vh] rounded-[0.5vh] bg-secondary hover:bg-opacity-90 border border-primary w-full"
			on:click={() => {
				SendNUI('clickButton', {
					data: isGivingMoney ? 'give_money' : 'remove_money',
					selectedData: {
						Player: { value: $SELECTED_PLAYER.id },
						Type: { value: moneyType },
						Amount: { value: moneyAmount },
					},
				});
				showMoneyModal = false;
			}}
		>
			<p>{isGivingMoney ? 'Confirmar Envio' : 'Confirmar Remoção'}</p>
		</button>
	</Modal>
{/if}

{#if showActionButton}
  <ConfirmAction
    {confirmText}
    onConfirm={confirmAction}
    onCancel={() => (showActionButton = false)}
  />
{/if}

{#if showGiveItemModal}
  <GiveItemModal
    player={$SELECTED_PLAYER}
    onClose={() => (showGiveItemModal = false)}
  />
{/if}

{#if showGroupModal}
  <ChangeGroupModal type={groupType} onClose={() => (showGroupModal = false)} />
{/if}
