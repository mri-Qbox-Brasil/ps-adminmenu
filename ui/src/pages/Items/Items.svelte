<script lang="ts">
	import { MENU_WIDE } from '@store/stores';
	import { ITEMS } from '@store/server';
	import Header from '@components/Header.svelte';
	import Autofill from '@components/Autofill.svelte';
	import Modal from '@components/Modal.svelte';
	import { SendNUI } from '@utils/SendNUI';

	let search = '';
	let isModalOpen = false;
	let selectedItem: any = null;
	let selectedPlayer: any = null;
	let quantity = 1;
	let imageError = {};

	$: SortedItems = $ITEMS
		? $ITEMS.slice().sort((a: any, b: any) => (a.name || '').localeCompare(b.name || ''))
		: [];
	$: FilteredItems = SortedItems.filter(
		(item: any) =>
			(item.name || '').toLowerCase().includes(search.toLowerCase()) ||
			(item.item || '').toLowerCase().includes(search.toLowerCase()) ||
			(item.description && item.description.toLowerCase().includes(search.toLowerCase()))
	);

	const getImageUrl = (itemId: any) =>
		`https://cfx-nui-ox_inventory/web/images/${itemId}.png`;

	function openModal(item: any) {
		selectedItem = item;
		isModalOpen = true;
		quantity = 1;
	}

	function closeModal() {
		isModalOpen = false;
		selectedItem = null;
		selectedPlayer = null;
		quantity = 1;
	}

	function handleImgError(itemId: any) {
		imageError = { ...imageError, [itemId]: true };
	}

	async function spawnItemForPlayer() {
		if (!selectedPlayer || !selectedItem || quantity <= 0) {
			return;
		}

		SendNUI('clickButton', {
			type: 'server',
			data: 'give_item',
			selectedData: {
				["Player"]: { value: selectedPlayer.value },
				["Item"]: { value: selectedItem.item },
				["Amount"]: { value: quantity },
			},
		});

		closeModal();
	}
</script>

<div class={`h-full ${$MENU_WIDE ? 'w-full' : 'w-[33vh]'} px-4`}>
	<div class="flex flex-col h-full gap-4">
		<Header
			title="Itens"
			hasSearch={true}
			hasLargeMenu={true}
			onSearchInput={(event) => (search = event.target.value)}
		/>

		<div class="w-full h-[84%] flex flex-col gap-4 mt-4 overflow-auto">
			{#if $ITEMS}
				{#if FilteredItems.length === 0}
					<div class="text-gray-500 text-center text-sm font-medium mt-4">
						Nenhum item encontrado.
					</div>
				{:else}
					<small class="text-gray-400 font-medium">
						Total de Itens: {SortedItems.length}
					</small>
					{#each FilteredItems as item (item.item)}
						<div class="relative flex items-center gap-4 bg-secondary p-4 rounded-lg shadow-md">
							<div class="flex items-center justify-center min-w-[6rem] min-h-[6rem] max-w-[6rem] max-h-[6rem] bg-[#2c2c2c] border border-[#444] rounded">
								{#if !imageError[item.item]}
									<img
										src={getImageUrl(item.item)}
										alt={item.name || 'Sem nome'}
										class="object-contain w-full h-full"
										on:error={() => handleImgError(item.item)}
									/>
								{:else}
									<i class="fa-solid fa-box text-4xl text-gray-500"></i>
								{/if}
							</div>
							<div class="flex flex-col flex-grow">
								<span class="text-white font-bold text-2xl truncate">
									{$MENU_WIDE ? item.name || 'Sem nome' : (item.name || 'Sem nome').substring(0, 20) + (item.name.length > 20 ? '...' : '')}
								</span>
								<span class="text-gray-400 text-xl">
									{item.description || 'Sem descrição disponível.'}
								</span>
								<div class="flex justify-between text-lg text-gray-300 font-medium mt-2">
									<span>ID: {item.item || 'N/A'}</span>
								</div>
							</div>
							<div class="absolute bottom-4 right-4 text-gray-300 text-sm font-medium">
								{item.weight || 'N/A'} kg
							</div>
							<button
								class="spawn-button absolute top-4 right-4 bg-green-600 hover:bg-green-500 text-white px-4 py-2 rounded"
								on:click={() => openModal(item)}
							>
								Spawnar
							</button>
						</div>
					{/each}
				{/if}
			{/if}
		</div>
	</div>
</div>

{#if isModalOpen}
	<Modal>
		<div class="flex justify-between">
			<p class="font-medium text-[1.8vh]">Dar Item: {selectedItem?.name}</p>
			<button class="hover:text-accent" on:click={closeModal}>
				<i class="fas fa-xmark"></i>
			</button>
		</div>
		<Autofill
			label_title="Selecionar Jogador"
			data="players"
			selectedData={(data) => (selectedPlayer = data)}
		/>
		<div class="mt-4">
			<label class="block text-sm font-medium text-gray-300">Quantidade</label>
			<input
				type="number"
				min="1"
				bind:value={quantity}
				class="w-full px-3 py-2 border border-gray-600 rounded bg-tertiary text-white"
			/>
		</div>
		<button
			class="mt-4 h-[3.8vh] px-[1.5vh] rounded-[0.5vh] bg-secondary hover:bg-opacity-90 border-[0.1vh] border-primary"
			on:click={spawnItemForPlayer}
		>
			<p>Confirmar</p>
		</button>
	</Modal>
{/if}

<style>
	.item-image {
		min-width: 6rem;
		min-height: 6rem;
		max-width: 6rem;
		max-height: 6rem;
		border-radius: 0.25rem;
		border: 1px solid #444;
		object-fit: cover;
		background-color: #2c2c2c;
		background-size: cover;
		background-position: center;
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 0.8rem;
		color: #999;
	}

	.item-image[data-fallback='true'] {
		background-image: url('https://via.placeholder.com/64?text=No+Image');
	}

	.spawn-button {
		cursor: pointer;
		font-size: 1rem;
		font-weight: bold;
		transition: background-color 0.3s;
		position: absolute;
		top: 1rem;
		right: 1rem;
	}

	.spawn-button:hover {
		background-color: #45a049;
	}

	.text-gray-300.absolute {
		position: absolute;
		bottom: 1rem;
		right: 1rem;
	}

	.truncate {
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}
</style>