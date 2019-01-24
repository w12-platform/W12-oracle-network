
ADDR = 'localhost:8888'



MAIN_PAGE_COMPONENT =
	'
<div>
	<div ref="container" class="container">

	</div>

</div>
	'

MAIN_PAGE = Vue.component 'main-page',
	template: MAIN_PAGE_COMPONENT
	data: =>
		login: DATA.login

	created: ->
		return


	mounted: ->
		@update()
		return


	methods:

		update: ->

			try

				log ''

			catch err
				log err


			setTimeout =>
				@update()
			,3000
			return
