%Este código replica los resultados de Gode & Sunder (1993)
%A partir de intercambios de agentes irracionales emerge la racionalidad
%Se observa que el precio promedio converge al precio de equilibrio teórico
clearvars;
clc;

%define parameters variables
S = 500; % # sellers
B = 500; % # buyers
T = 10000; % # iteraciones
max_valuation = 25; % máxima valuacion
max_cost = 25;		% máximo costo
max_price = 50;		% Precio máximo que establecen los productores

min_valuation = 0;  %valuacion minima
min_cost = 0;		%costo minimo

index_S = [1:S];    %indice de sellers
index_B = [1:B];	%indice de buyers

index_S = index_S';	%reexpreso
index_B = index_B'; %reexpreso

unmatched_consumers =  index_B; %lista de unmatched consumers
unmatched_sellers = index_S; %lista de unmatched sellers

matched_consumers = []; %lista de matched consumers
matched_sellers = []; %%lista de matched sellers

price_record=[]; %precios de transacción


rng(0.5) % Specifies the seed for the random number generator   

%Genero valuaciones con distribución uniforme
valuations = round(min_valuation + (max_valuation-min_valuation).*rand(B,1),1); %numeros reales
%valuations = randi([min_valuation max_valuation],B,1); %numeros enteros
valuations = sort(valuations, 'descend');
buyers = [index_B valuations]; 

%Genero costos con distribución uniforme
cost = round(min_cost + (max_cost-min_cost).*rand(S,1),1);  %numeros reales
%cost = randi([min_cost max_cost],S,1); %numeros enteros
cost = sort(cost, 'ascend');
sellers = [index_S cost];

%Determinar precio y cantidad de equilibrio
quantity_equilibrium = find(valuations == cost);
quantity_equilibrium = quantity_equilibrium(1); 
price_equilibrium = valuations(quantity_equilibrium);

%Proceso de matching
for t=1:T	
	a=0;
	
	for i=1:B
		bids(i,1)=  round(min_valuation + (buyers(i,2)-min_valuation).*rand(1,1),1); %bids aleatorias cada período
	end

	for i=1:S
		offers(i,1)=  round(sellers(i,2) + (max_price-sellers(i,2)).*rand(1,1),1); %offers aleatorias cada período
	end
	
	x = unmatched_consumers(randperm(length(unmatched_consumers))); %Lista de unmatched consumers aleteria
	y = unmatched_sellers(randperm(length(unmatched_sellers)));	%Lista de unmatched sellers aleteria
	
	for i=1:length(unmatched_consumers)
			if bids(x(i)) >= offers(y(i))
				a=a+1;
				price_record(a,t) = (bids(x(i))+offers(y(i)))/2; %precio de intercambio

				matched_consumers(end+1) = x(i);				%consumers matcheados
				matched_sellers(end+1) = y(i);					%sellers matcheados			
			end		
	end	
	
	for j=1:length(matched_consumers)	
		unmatched_consumers(unmatched_consumers == matched_consumers(j)) = []; %actualizo lista de unmatched
		unmatched_sellers(unmatched_sellers == matched_sellers(j)) = [];		%actualizo lista de unmatched
	end
end

variability = nonzeros(price_record); %elimina los ceros del vector price_record

price_history = sum(price_record); 


for i=1:length(price_history)	
		if price_history(i)>0
			mean_price(i)=price_history(i)/length(find(price_record(:,i)));	%calcula precio promedio de cada período de intercambio
		elseif price_history(i)==0
			mean_price(i)=0;
		end
end

mean_price(mean_price==0) = []; %elmino los ceros

price_record(price_record==0) = []; %elmino los ceros
price_distribution = price_record;


[F,pi] = ksdensity(price_distribution); %estimo densidad de la distribución de precios


figure
subplot(1,2,1) %market equilibrium
stairs(buyers(:,1), buyers(:,2), 'LineWidth',2)
set(gca,'FontSize',15)
%plot(buyers(:,1), buyers(:,2),'.')
hold on
stairs(sellers(:,1), sellers(:,2), 'LineWidth',2)
%plot(sellers(:,1), sellers(:,2),'.')
hold on
line([quantity_equilibrium;quantity_equilibrium],[0;price_equilibrium], 'color', 'k','linestyle','--');
line([0;quantity_equilibrium],[price_equilibrium;price_equilibrium], 'color', 'k','linestyle','--');
legend('Location','northeast', 'Demand', 'Supply');
xlim([0, B])
ylim([min_valuation, max_valuation])
xlabel('Quantity')
ylabel('Price');	
xticks([0 100 200 quantity_equilibrium 300 400 500]);
xticklabels({'0', '100' '200', 'q*' '300', '400', '500'});
yticks([0 5 10 price_equilibrium 15 20 25]);
yticklabels({'0', '5' '10', 'p*' '15', '20', '25'});
title('Market Equilibrium', 'FontSize', 20);

subplot(1,2,2) %variabilidad de precios. Muestra los precios en cada transacción
plot(variability, 'LineWidth',1.2) % 'Color', 'k'
set(gca,'FontSize',15)
hold on
line(buyers(:,1), ones(1,B)*price_equilibrium, 'color', 'black'); 
xlim([0, length(variability)])
ylim([min_valuation, max_valuation])
xlabel('Quantity')
ylabel('Price');	
title('Price Variability', 'FontSize', 20);
yticks([0 5 10 price_equilibrium 15 20 25]);
yticklabels({'0', '5' '10', 'p*' '15', '20', '25'});

figure
subplot(1,2,1) %Convergencia del precio promedio al precio de equilibrio
plot(mean_price, 'LineWidth',1.5) %'Color', 'b'
set(gca,'FontSize',15)
hold on
line(buyers(:,1), ones(1,B)*price_equilibrium, 'color', 'black');
xlim([0, length(mean_price)])
ylim([min_valuation, max_valuation])
xlabel('Period')
ylabel('Average Price');	
title('Convergence', 'FontSize', 20);
yticks([0 5 10 price_equilibrium 15 20 25]);
yticklabels({'0', '5' '10', 'p*' '15', '20', '25'});

%{
figure
scatter([1:length(mean_price)], mean_price, '.')
hold on
line(buyers(:,1), ones(1,B)*price_equilibrium, 'color', 'red');
xlim([0, length(mean_price)])
ylim([min_valuation, max_valuation])
xlabel('Period')
ylabel('Average Price');	
title('Convergence');
%}

subplot(1,2,2) %Distribución de precios de intercambio
plot(pi,F, 'LineWidth',2); 
set(gca,'FontSize',15)
hold on
line([price_equilibrium;price_equilibrium],[0;max(F)], 'color', 'k','linestyle','--');
xlim([min(pi) max(pi)])
title('Price Distribution', 'FontSize', 20);
xlabel('Price')
ylabel('Probability');
xticks([0 5 10 price_equilibrium 15 20 25]);
xticklabels({'0', '5' '10', 'p*' '15', '20', '25'});





