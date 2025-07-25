<script lang="ts">
import Header from '@components/Header.svelte';
import Spinner from '@components/Spinner.svelte';
import { onMount } from 'svelte';
import { SendNUI } from '@utils/SendNUI';
import ConfirmAction from '@pages/Players/components/ConfirmAction.svelte';
import ActionButton from '@pages/Players/components/ActionButton.svelte';
import { MENU_WIDE } from '@store/stores';
import { tick } from 'svelte';
import { ReceiveNUI } from '@utils/ReceiveNUI';

let bans: any[] = [];
let loading = false;
let search = '';
let showConfirm = false;
let confirmText = '';
let confirmAction: () => void = () => {};
let selectedBan = null;

function openConfirm(ban: any) {
  confirmText = `Deseja realmente desbanir ${ban.name}?`;
  selectedBan = ban;
  showConfirm = true;
  confirmAction = async () => {
    showConfirm = false;
    await SendNUI('clickButton', {
      data: 'unban_rowid',
      selectedData: { ban_id: { value: ban.id } }
    });
    await fetchBans();
  };
}

async function fetchBans() {
  loading = true;
  try {
    const result = await SendNUI('ps-adminmenu:callback:GetBans');
    bans = [];
    await tick();
    bans = result ? [...result] : [];
  } catch (e) {
    bans = [];
  } finally {
    loading = false;
  }
}

onMount(fetchBans);

ReceiveNUI('refreshBans', () => {
  fetchBans();
});

function formatDate(ts: number | string) {
  if (!ts) return 'N/A';
  const d = new Date(ts * 1000);
  return d.toLocaleString('pt-BR');
}

function filterBans(ban: any) {
  const s = search.toLowerCase();
  return (
    (ban.name && ban.name.toLowerCase().includes(s)) ||
    (ban.reason && ban.reason.toLowerCase().includes(s)) ||
    (ban.license && ban.license.toLowerCase().includes(s))
  );
}
</script>

<div class="h-full w-full px-[2vh]">
  <Header
    title={'Banimentos'}
    hasSearch={true}
    onSearchInput={(event) => (search = event.target.value)}
  />
  <div class="w-full h-[90%] flex flex-col gap-[1vh] mt-[1vh] overflow-auto">
    {#if loading}
      <Spinner />
    {:else}
      {#if bans.filter(filterBans).length === 0}
        <div class="text-accent text-center text-[1.7vh] font-medium mt-[1vh]">Nenhum banimento encontrado.</div>
      {:else}
        <div class="overflow-auto rounded-lg shadow">
          <table class="w-full text-left bg-tertiary rounded-lg overflow-hidden">
            <thead class="bg-primary text-accent text-md uppercase sticky top-0 z-10">
              <tr>
                <th class="px-4 py-2 min-w-[120px]">Nome</th>
                <th class="px-4 py-2 min-w-[100px]">Motivo</th>
                <th class="px-4 py-2 min-w-[90px]">Expira</th>
                <th class="px-4 py-2 min-w-[120px]">Banido por</th>
                <th class="px-4 py-2 min-w-[110px]">License</th>
                <th class="px-4 py-2 min-w-[90px] hidden md:table-cell">Discord</th>
                <th class="px-4 py-2 min-w-[90px] hidden md:table-cell">IP</th>
                <th class="px-4 py-2 text-center min-w-[100px]">Ação</th>
              </tr>
            </thead>
            <tbody>
              {#each bans.filter(filterBans) as ban, i}
                <tr class="border-b border-primary/20 hover:bg-primary/40 transition {i % 2 === 0 ? 'bg-tertiary' : 'bg-primary/10'}">
                  <td class="px-4 py-2 font-bold truncate" title={ban.name}>{ban.name || 'Desconhecido'}</td>
                  <td class="px-4 py-2 truncate" title={ban.reason}>{ban.reason || 'N/A'}</td>
                  <td class="px-4 py-2">
                    {#if ban.expire == 2147483647}
                      <span class="bg-red-600 text-white text-md px-2 py-0.5 rounded-full">Permanente</span>
                    {:else if ban.expire}
                      <span class="bg-yellow-600 text-white text-md px-2 py-0.5 rounded-full">{formatDate(ban.expire)}</span>
                    {:else}
                      <span class="bg-zinc-600 text-white text-md px-2 py-0.5 rounded-full">N/A</span>
                    {/if}
                  </td>
                  <td class="px-4 py-2 truncate" title={ban.bannedby}>{ban.bannedby || 'N/A'}</td>
                  <td class="px-4 py-2 truncate" title={ban.license}>{ban.license}</td>
                  <td class="px-4 py-2 hidden md:table-cell truncate" title={ban.discord}>{ban.discord || 'N/A'}</td>
                  <td class="px-4 py-2 hidden md:table-cell truncate" title={ban.ip}>{ban.ip || 'N/A'}</td>
                  <td class="px-4 py-2 text-center">
                    <button
                      class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg flex items-center gap-2 shadow transition group"
                      title="Desbanir este jogador"
                      on:click={() => openConfirm(ban)}
                    >
                      <i class="fa-solid fa-unlock group-hover:animate-bounce"></i> Desbanir
                    </button>
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      {/if}
    {/if}
  </div>
</div>

{#if showConfirm}
  <ConfirmAction
    {confirmText}
    onConfirm={confirmAction}
    onCancel={() => (showConfirm = false)}
  />
{/if}