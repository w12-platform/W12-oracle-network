<template>

	<section class="container">
		<h2 class="content__heading sb30">{{ $t('OracleAdd') }}</h2>

		<b-table
				:data="voters"
				:mobile-cards="true"
				paginated
				per-page="10"
				pagination-simple>
			<template slot-scope="props">

				<b-table-column field="date" :label="$t('OracleTableAddr')" :title="props.row.addr">
					<span class="tag is-success">{{ props.row.addr | shortAddress }}</span>
				</b-table-column>

				<b-table-column field="date" :label="$t('OracleTableType')">
					{{ props.row.type }}
				</b-table-column>

				<b-table-column field="date" :label="$t('OracleTableStatus')" centered>
					{{ props.row.status }}
				</b-table-column>
			</template>

		</b-table>


		<div class="form-group sb30">
			<label>{{ $t('OracleAddress') }}</label>
			<b-field>
				<input type="text" class="form-control"/>
			</b-field>
		</div>

		<div class="form-group sb30">
			<label>{{ $t('OracleInfo') }}</label>
			<b-field>
				<textarea type="text" class="form-control"/>
			</b-field>
		</div>


		<b-field class="ProjectSwitch sb30">
			<b-select @input="input55" :placeholder="$t('OracleSelectType')" expanded>
				<option>0</option>
				<option>1</option>
				<option>2</option>
				<option>3</option>
				<option>4</option>
			</b-select>
		</b-field>

		<b-field class="ProjectSwitch sb30">
			<b-select @input="input55" :placeholder="$t('OracleSelectStatus')" expanded>
				<option>0</option>
				<option>1</option>
			</b-select>
		</b-field>

		<button
				class="btn sb100 btn-primary py-2 my-2"
				:disabled="false">{{
			$t('OracleAdd')}}
		</button>

	</section>

</template>

<script>
	import './default.scss';
  import Eth from 'ethjs';

	window.log = console.log;


	export default {
		name: 'OracleEdit',

		filters:
				{
					shortAddress(value)
					{
						const length = value.length;
						return value.slice(0, 8) + " ... " + value.slice(length - 8, length);
					},
					percentFractional(value)
					{
						return value / 100;
					},
				},

		components: {},
		data()
		{
			return {voters: [{addr: 'asdads', type: 'asdasd', status: 'true'}]}
		},

		computed:
				{},
		methods:
				{
					input55()
					{

					},
				},
		async created()
		{
			if(window.eth === undefined)
			{
				if(typeof web3 === 'undefined')
				{
					window.addEventListener('message', ({data}) => {
						if(data && data.type && data.type === 'ETHEREUM_PROVIDER_SUCCESS')
						{
							window.eth = new Eth('ethereum');
						}
					});
					window.postMessage({type: 'ETHEREUM_PROVIDER_REQUEST'}, '*');
				}
				else
				{
					window.eth = new Eth(web3.currentProvider);
				}
			}
		},
	};
</script>
