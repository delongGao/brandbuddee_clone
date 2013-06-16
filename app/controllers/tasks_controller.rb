class TasksController < ApplicationController
	def check_engage_left
		@task = Task.where(_id: params[:task]).first
		unless @task.nil?
			ip_address = request.remote_ip
			if current_user
				if @task.user_id == current_user.id
					redirect_to @task.task_1_url
				else
					@click = @task.task_clicks.where(ip_address: ip_address, task_number: 1).first
					if @click.nil?
						@task.task_1_clicks += 1
						@task.task_1_uniques += 1
						@task.task_clicks.create!(ip_address: ip_address, views: 1, task_number: 1)
						if @task.save
							redirect_to @task.task_1_url
						else
							UserMailer.email_brice_error("Controller: tasks_controller.rb | Action: check_engage_left | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
							redirect_to @task.task_1_url
						end
					else
						@task.task_1_clicks += 1
						@click.views += 1
						if @click.save && @task.save
							redirect_to @task.task_1_url
						else
							UserMailer.email_brice_error("Controller: tasks_controller.rb | Action: check_engage_left | Issue: The statement: if if @click.save && @task.save, did not save and instead went to the else portion below.").deliver
							redirect_to @task.task_1_url
						end
					end
				end
			else
				@click = @task.task_clicks.where(ip_address: ip_address, task_number: 1).first
				if @click.nil?
					@task.task_1_clicks += 1
					@task.task_1_uniques += 1
					@task.task_clicks.create!(ip_address: ip_address, views: 1, task_number: 1)
					if @task.save
						redirect_to @task.task_1_url
					else
						UserMailer.email_brice_error("Controller: tasks_controller.rb | Action: check_engage_left | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
						redirect_to @task.task_1_url
					end
				else
					@task.task_1_clicks += 1
					@click.views += 1
					if @click.save && @task.save
						redirect_to @task.task_1_url
					else
						UserMailer.email_brice_error("Controller: tasks_controller.rb | Action: check_engage_left | Issue: The statement: if @click.save && @task.save, did not save and instead went to the else portion below.").deliver
						redirect_to @task.task_1_url
					end
				end
			end
		else
			redirect_to root_url
		end
	end

	def check_engage_right
		@task = Task.where(_id: params[:task]).first
		unless @task.nil?
			ip_address = request.remote_ip
			if current_user
				if @task.user_id == current_user.id
					redirect_to @task.task_2_url
				else
					@click = @task.task_clicks.where(ip_address: ip_address, task_number: 2).first
					if @click.nil?
						@task.task_2_clicks += 1
						@task.task_2_uniques += 1
						@task.task_clicks.create!(ip_address: ip_address, views: 1, task_number: 2)
						if @task.save
							redirect_to @task.task_2_url
						else
							UserMailer.email_brice_error("Controller: tasks_controller.rb | Action: check_engage_right | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
							redirect_to @task.task_2_url
						end
					else
						@task.task_2_clicks += 1
						@click.views += 1
						if @click.save && @task.save
							redirect_to @task.task_2_url
						else
							UserMailer.email_brice_error("Controller: tasks_controller.rb | Action: check_engage_right | Issue: The statement: if if @click.save && @task.save, did not save and instead went to the else portion below.").deliver
							redirect_to @task.task_2_url
						end
					end
				end
			else
				@click = @task.task_clicks.where(ip_address: ip_address, task_number: 2).first
				if @click.nil?
					@task.task_2_clicks += 1
					@task.task_2_uniques += 1
					@task.task_clicks.create!(ip_address: ip_address, views: 1, task_number: 2)
					if @task.save
						redirect_to @task.task_2_url
					else
						UserMailer.email_brice_error("Controller: tasks_controller.rb | Action: check_engage_right | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
						redirect_to @task.task_2_url
					end
				else
					@task.task_2_clicks += 1
					@click.views += 1
					if @click.save && @task.save
						redirect_to @task.task_2_url
					else
						UserMailer.email_brice_error("Controller: tasks_controller.rb | Action: check_engage_right | Issue: The statement: if @click.save && @task.save, did not save and instead went to the else portion below.").deliver
						redirect_to @task.task_2_url
					end
				end
			end
		else
			redirect_to root_url
		end
	end
end