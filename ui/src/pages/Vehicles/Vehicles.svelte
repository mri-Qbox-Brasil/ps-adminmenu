<script lang="ts">
	import { MENU_WIDE } from '@store/stores';
	import { VEHICLES } from '@store/server';
import Header from '@components/Header.svelte';
import { SendNUI } from '@utils/SendNUI';

	let search = '';

	$: SortedVehicles = $VEHICLES
		? $VEHICLES.slice().sort((a: any, b: any) => (a.name || '').localeCompare(b.name || ''))
		: [];
	$: FilteredVehicles = SortedVehicles.filter((vehicle: any) =>
		[
			vehicle.name?.toLowerCase(),
			vehicle.plate?.toLowerCase(),
			vehicle.model?.toLowerCase(),
		].some((field) => field?.includes(search.toLowerCase()))
	);

	function spawnVehicle(vehicle) {
		SendNUI('clickButton', {
			type: 'client',
			data: 'spawn_vehicle',
			selectedData: {
				["Vehicle"]: { value: vehicle.model },
			},
		});
	}

	const getPrimaryImage = (model: string) =>
		`https://cfx-nui-ox_inventory/web/images/${model}.png`;

	const getFallbackImage = (model: string) =>
		`https://docs.fivem.net/vehicles/${model}.webp`;

	// No NUI, aponte para a pasta de imagens dentro do recurso (html/vehicles)
	const getNuiResourceImage = (model: string, upper = false) =>
		`vehicles/${model}.${upper ? 'PNG' : 'png'}`;

	const LOCAL_FS_PREFIX = '/@fs/C:/Users/bruno/Downloads/mri_assets-main/vehicles';
	const getLocalImage = (model: string, ext: 'png' | 'PNG' = 'png') =>
		`${LOCAL_FS_PREFIX}/${model}.${ext}`;

	let imageStatus: Record<string, 'nui-PNG' | 'primary' | 'local-PNG' | 'fallback' | 'failed'> = {};

	function onImageError(hash: any) {
		const key = String(hash);
		const status = imageStatus[key];
		if (isNUI) {
			// NUI: vehicles (png) -> vehicles (PNG) -> ox_inventory -> docs -> placeholder
			imageStatus = {
				...imageStatus,
				[key]: status === 'primary'
					? 'fallback'
					: status === 'nui-PNG'
					? 'primary'
					: status === 'fallback'
					? 'failed'
					: 'nui-PNG',
			};
		} else {
			// Dev: local (png) -> local (PNG) -> docs -> placeholder
			imageStatus = {
				...imageStatus,
				[key]: status === 'local-PNG' ? 'fallback' : status === 'fallback' ? 'failed' : 'local-PNG',
			};
		}
	}

	const isNUI = typeof (window as any).GetParentResourceName === 'function';
</script>


<div class={`h-full ${$MENU_WIDE ? 'w-full' : 'w-[33vh]'} px-4`}>
	<div class="flex flex-col h-full gap-4">
		<Header
			title="Veículos"
			hasSearch={true}
			hasLargeMenu={$MENU_WIDE}
			onSearchInput={(event) => (search = event.target.value)}
		/>

		<div class="w-full h-[84%] flex flex-col gap-4 mt-4 overflow-auto">
			{#if $VEHICLES}
				{#if FilteredVehicles.length === 0}
					<div class="text-gray-500 text-center text-sm font-medium mt-4">
						Nenhum veículo encontrado.
					</div>
				{:else}
					<small class="text-gray-400 font-medium">
						Total de Veículos: {SortedVehicles.length}
					</small>
					{#each FilteredVehicles as vehicle (vehicle.hash)}
						<div class="relative flex items-center gap-6 bg-secondary p-6 rounded-lg shadow-md">
						{#if imageStatus[String(vehicle.hash)] !== 'failed'}
							<div class="flex items-center justify-center w-[128px] h-[80px] bg-zinc-800 rounded-lg">
								<img
									src={(() => {
										const key = String(vehicle.hash);
										const status = imageStatus[key];
										if (isNUI) {
											// NUI: primeiro vehicles dentro do recurso, depois ox_inventory e docs
											if (status === 'fallback') return getFallbackImage(vehicle.model);
											if (status === 'primary') return getPrimaryImage(vehicle.model);
											if (status === 'nui-PNG') return getNuiResourceImage(vehicle.model, true);
											return getNuiResourceImage(vehicle.model, false);
										} else {
											// Dev: primeiro pasta local, depois docs
											if (status === 'fallback') return getFallbackImage(vehicle.model);
											if (status === 'local-PNG') return getLocalImage(vehicle.model, 'PNG');
											return getLocalImage(vehicle.model, 'png');
										}
									})()}
									alt={vehicle.name || 'Desconhecido'}
									class="vehicle-image w-full h-full"
									loading="lazy"
									decoding="async"
									on:error={() => onImageError(vehicle.hash)}
								/>
							</div>
						{:else}
							<div class="flex items-center justify-center w-[128px] h-[80px] bg-zinc-800 rounded-lg">
								<i class="fa-solid fa-car text-5xl text-gray-500"></i>
							</div>
						{/if}
							<div class="flex flex-col flex-grow">
								<span class="text-white font-bold text-xl truncate">
									{vehicle.name || 'Desconhecido'}
								</span>
								<div class="text-gray-400 text-base">
									Marca: {vehicle.brand || 'Sem marca'}
								</div>
								<div class="text-gray-400 text-base">
									Categoria: {vehicle.category || 'Sem categoria'}
								</div>
								<div class="flex justify-between text-base text-gray-300 font-medium mt-2">
									<span>Modelo: {vehicle.model || 'N/A'}</span>
									<span>Preço: ${vehicle.price || 'N/A'}</span>
								</div>
							</div>
							<button
								class="spawn-button absolute top-4 right-4 bg-green-600 hover:bg-green-500 text-white px-4 py-2 rounded"
								on:click={() => spawnVehicle(vehicle)}
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

<style>
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

	.truncate {
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.vehicle-image {
		width: 10rem;
		height: 6rem;
		object-fit: cover;
		border: 1px solid #444;
		background-color: #2c2c2c;

		/* Adicionando propriedades para suavização */
		image-rendering: auto;
		image-rendering: smooth;
	}

</style>
