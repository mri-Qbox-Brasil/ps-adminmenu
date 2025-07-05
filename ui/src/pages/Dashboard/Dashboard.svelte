<script>
    import Header from '@components/Header.svelte';
    import Spinner from '@components/Spinner.svelte';
    import { onMount } from 'svelte';
    import { SendNUI } from '@utils/SendNUI';
    import { get } from 'svelte/store';
    import { BROWSER_MODE } from '@store/stores';

    // Seus mocks diretos
    const mockPlayers = [
        {
            id: "1",
            name: "John Doe",
            cid: "ERP95808",
            cash: 2000,
            bank: 50000,
            crypto: 120,
        },
        {
            id: "2",
            name: "Jane Smith",
            cid: "ERP87521",
            cash: 1500,
            bank: 30000,
            crypto: 70,
        }
    ];

    const mockSummary = {
        totalCash: 15000,
        totalBank: 200000,
        totalCrypto: 1000,
        uniquePlayers: 42,
        vehicleCount: 140,
        bansCount: 5,
        characterCount: 70,
    };

    let loading = true;
    let errorMessage = '';
    let searchQuery = '';
    let summary = {
        totalCash: 0,
        totalBank: 0,
        totalCrypto: 0,
        uniquePlayers: 0,
        vehicleCount: 0,
        bansCount: 0,
        characterCount: 0,
    };
    let players = [];
    let sortedPlayers = [];
    let sortKey = 'bank';
    let sortOrder = 'desc';

    async function fetchDashboardData() {
        const browserMode = get(BROWSER_MODE);

        try {
            loading = true;

            if (browserMode) {
                players = mockPlayers;
                summary = mockSummary;
                sortPlayers();
            } else {
                const serverInfo = await SendNUI('getServerInfo');
                if (serverInfo) {
                    summary = {
                        totalCash: serverInfo.totalCash || 0,
                        totalBank: serverInfo.totalBank || 0,
                        totalCrypto: serverInfo.totalCrypto || 0,
                        uniquePlayers: serverInfo.uniquePlayers || 0,
                        vehicleCount: serverInfo.vehicleCount || 0,
                        bansCount: serverInfo.bansCount || 0,
                        characterCount: serverInfo.characterCount || 0,
                    };
                } else {
                    throw new Error('Dados inválidos do servidor');
                }

                const fetchedPlayers = await SendNUI('getPlayers');
                if (fetchedPlayers && Array.isArray(fetchedPlayers)) {
                    players = fetchedPlayers;
                    sortPlayers();
                } else {
                    throw new Error('Dados inválidos de jogadores');
                }
            }
        } catch (error) {
            errorMessage = error.message || 'Erro ao carregar dados';
        } finally {
            loading = false;
        }
    }

    function sortPlayers() {
        sortedPlayers = [...players]
            .filter(player =>
                player.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
                player.cid?.toLowerCase().includes(searchQuery.toLowerCase())
            )
            .sort((a, b) => {
                if (sortKey === 'name') {
                    return sortOrder === 'asc'
                        ? a.name.localeCompare(b.name)
                        : b.name.localeCompare(a.name);
                }
                if (sortOrder === 'asc') {
                    return (a[sortKey] || 0) - (b[sortKey] || 0);
                } else {
                    return (b[sortKey] || 0) - (a[sortKey] || 0);
                }
            });
    }

    function setSort(key) {
        if (sortKey === key) {
            sortOrder = sortOrder === 'asc' ? 'desc' : 'asc';
        } else {
            sortKey = key;
            sortOrder = 'desc';
        }
        sortPlayers();
    }

    onMount(fetchDashboardData);
</script>

<div class="h-full w-full px-6 py-6 bg-primary text-white">
    <Header title={'Dashboard de Jogadores'} />

    {#if loading}
        <div class="flex justify-center items-center h-full">
            <Spinner />
        </div>
    {:else if errorMessage}
        <div class="text-red-500 text-center font-bold">{errorMessage}</div>
    {:else}
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 mb-6">
            <div class="bg-secondary p-4 rounded-lg shadow flex items-center">
                <i class="fas fa-wallet text-accent text-3xl mr-4"></i>
                <div>
                    <h3 class="text-lg font-semibold">Dinheiro em Mãos</h3>
                    <p class="text-xl font-bold">R$ {summary.totalCash}</p>
                </div>
            </div>
            <div class="bg-secondary p-4 rounded-lg shadow flex items-center">
                <i class="fas fa-piggy-bank text-green-500 text-3xl mr-4"></i>
                <div>
                    <h3 class="text-lg font-semibold">Dinheiro no Banco</h3>
                    <p class="text-xl font-bold">R$ {summary.totalBank}</p>
                </div>
            </div>
            <div class="bg-secondary p-4 rounded-lg shadow flex items-center">
                <i class="fas fa-coins text-yellow-500 text-3xl mr-4"></i>
                <div>
                    <h3 class="text-lg font-semibold">Criptomoedas</h3>
                    <p class="text-xl font-bold">R$ {summary.totalCrypto}</p>
                </div>
            </div>
            <div class="bg-secondary p-4 rounded-lg shadow flex items-center">
                <i class="fas fa-users text-blue-500 text-3xl mr-4"></i>
                <div>
                    <h3 class="text-lg font-semibold">Jogadores Únicos</h3>
                    <p class="text-xl font-bold">{summary.uniquePlayers}</p>
                </div>
            </div>
            <div class="bg-secondary p-4 rounded-lg shadow flex items-center">
                <i class="fas fa-car text-red-500 text-3xl mr-4"></i>
                <div>
                    <h3 class="text-lg font-semibold">Veículos</h3>
                    <p class="text-xl font-bold">{summary.vehicleCount}</p>
                </div>
            </div>
            <div class="bg-secondary p-4 rounded-lg shadow flex items-center">
                <i class="fas fa-ban text-purple-500 text-3xl mr-4"></i>
                <div>
                    <h3 class="text-lg font-semibold">Banimentos</h3>
                    <p class="text-xl font-bold">{summary.bansCount}</p>
                </div>
            </div>
            <div class="bg-secondary p-4 rounded-lg shadow flex items-center">
                <i class="fas fa-id-card text-teal-500 text-3xl mr-4"></i>
                <div>
                    <h3 class="text-lg font-semibold">Personagens</h3>
                    <p class="text-xl font-bold">{summary.characterCount}</p>
                </div>
            </div>
        </div>

        <div class="bg-secondary p-4 rounded-lg shadow">
            <input
                type="text"
                placeholder="Pesquisar por Nome ou CID..."
                bind:value={searchQuery}
                on:input={sortPlayers}
                class="w-full p-2 rounded-lg border border-border_primary bg-tertiary text-white mb-4"
            />

            <div class="overflow-auto max-h-[50vh]">
                <table class="w-full text-left border-collapse">
                    <thead class="sticky top-0 bg-tertiary">
                        <tr>
                            <th class="p-2">#</th>
                            <th class="p-2 cursor-pointer" on:click={() => setSort('name')}>
                                Nome (CitizenID)
                                {#if sortKey === 'name'}
                                    {#if sortOrder === 'asc'}
                                        <i class="fas fa-arrow-up ml-1"></i>
                                    {:else}
                                        <i class="fas fa-arrow-down ml-1"></i>
                                    {/if}
                                {/if}
                            </th>
                            <th class="p-2 cursor-pointer" on:click={() => setSort('bank')}>
                                Dinheiro no Banco
                                {#if sortKey === 'bank'}
                                    {#if sortOrder === 'asc'}
                                        <i class="fas fa-arrow-up ml-1"></i>
                                    {:else}
                                        <i class="fas fa-arrow-down ml-1"></i>
                                    {/if}
                                {/if}
                            </th>
                            <th class="p-2 cursor-pointer" on:click={() => setSort('cash')}>
                                Dinheiro na Mão
                                {#if sortKey === 'cash'}
                                    {#if sortOrder === 'asc'}
                                        <i class="fas fa-arrow-up ml-1"></i>
                                    {:else}
                                        <i class="fas fa-arrow-down ml-1"></i>
                                    {/if}
                                {/if}
                            </th>
                            <!-- Crypto -->
                            <th class="p-2 cursor-pointer" on:click={() => setSort('crypto')}>
                                Criptomoedas
                                {#if sortKey === 'crypto'}
                                    {#if sortOrder === 'asc'}
                                        <i class="fas fa-arrow-up ml-1"></i>
                                    {:else}
                                        <i class="fas fa-arrow-down ml-1"></i>
                                    {/if}
                                {/if}
                            </th>

                        </tr>
                    </thead>
                    <tbody>
                        {#each sortedPlayers as player, index}
                            <tr class="border-b border-border_primary">
                                <td class="p-2">{index + 1}</td>
                                <td class="p-2">{player.name || 'N/A'} ({player.cid || 'N/A'})</td>
                                <td class="p-2">R$ {player.bank || 0}</td>
                                <td class="p-2">R$ {player.cash || 0}</td>
                                <td class="p-2">{player.crypto || 0}</td>
                            </tr>
                        {/each}
                    </tbody>
                </table>
            </div>
        </div>
    {/if}
</div>
